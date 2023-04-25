.include "durango_constants.inc"
.PC02

;https://github.com/cc65/cc65/tree/master/libsrc/runtime
.importzp  sp
.import incsp3
.import incsp4
.import incsp5

.export _drawFullScreen
.export _drawPixel
.export _drawRect
.export _drawFillRect
.export _drawLine
.export _drawCircle


.proc _drawFullScreen: near
    LDX #>SCREEN_3
    STX VMEM_POINTER+1
    LDY #<SCREEN_3
    STY VMEM_POINTER
    loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
	INC VMEM_POINTER+1
    BPL loop
    RTS
.endproc


.proc _drawPixel: near
    ; Load x coord
    LDY #$02
    LDA (sp), Y
	TAX						; input for PLOT routine
    
    ; Load y coord
    LDY #$01
    LDA (sp), Y
    TAY						; input for PLOT routine

    ; Load color
;	LDY #$00
	LDA (sp)				; CMOS does not need ,Y
	STA COLOUR				; input for PLOT routine (actually px_col)
    
	JSR dxplot				; must call as it has many exit points
	JMP incsp3   			; Remove args from stack... and exit procedura

; *** input ***
; X = x coordinate (<128 in colour, <256 in HIRES)
; Y = y coordinate (<128 in colour, <256 in HIRES)
px_col	= COLOUR			; colour in II format (17*index, HIRES reads d7 only)

; *** zeropage usage ***
cio_pt	= VMEM_POINTER		; (screen pointer)
fw_cbyt	= TEMP1				; (temporary storage, could be elsewhere)

; *** usual addresses ***
IO8attr	= VIDEO_MODE		; compatible IO8lh for setting attributes (d7=HIRES, d6=INVERSE, now d5-d4 include screen block)

dxplot:
	STZ cio_pt				; common to all modes (3)
	TYA						; get Y coordinate... (2)
	LSR
	ROR cio_pt
	LSR
	ROR cio_pt				; divide by 4 instead of times 64, already OK for colour (2+5+2+5)
	BIT IO8attr				; check screen mode (4)
	BPL colplot				; * HIRES plot below * (3/2 for COLOUR/HIRES)
		LSR
		ROR cio_pt			; divide by 8 instead of times 32! (2+5)
		STA cio_pt+1		; LSB ready, temporary MSB (3)
		LDA IO8attr			; get flags... (4)
		AND #$30			; ...for the selected screen... (2)
		ASL					; ...and shift them to final position (2)
		ORA cio_pt+1
		STA cio_pt+1		; full pointer ready! (3+3)
		TXA					; get X coordinate (2)
		LSR
		LSR
		LSR					; 8 pixels per byte (2+2+2)
		TAY					; this is actual indexing offset (2)
		TXA					; X again (2)
		AND #7				; MOD 8 (2)
		TAX					; use as index (2)
		LDA pixtab, X		; get pixel within byte (4)
		BIT px_col			; check colour to plot (4*)
		BPL unplot_h		; alternative clear routine (2/3)
			ORA (cio_pt), Y		; add to previous data (5/ + 6/ + 6/)
			STA (cio_pt), Y
			RTS
unplot_h:
		EOR #$FF			; * HIRES UNPLOT * negate pattern (/2)
		AND (cio_pt), Y		; subtract pixel from previous data (/5 + /6 + /6)
		STA (cio_pt), Y
		RTS
colplot:
	STA cio_pt+1			; LSB ready, temporary MSB (3)
	LDA IO8attr				; get flags... (4)
	AND #$30				; ...for the selected screen... (2)
	ASL						; ...and shift them to final position (2)
	ORA cio_pt+1			; add to MSB (3+3)
	STA cio_pt+1
	TXA						; get X coordinate (2)
	LSR						; in half (C is set for odd pixels) (2)
	TAY						; this is actual indexing offset (2)
	LDA #$0F				; _inverse_ mask for even pixel (2)
	LDX #$F0				; and colour mask for it (2)
	BCC evpix
		LDA #$F0			; otherwise is odd (3/2+2+2 for even/odd)
		LDX #$0F
evpix:
	AND (cio_pt), Y			; keep original data in byte... (5)
	STA fw_cbyt				; store temporarily (4*)
	TXA						; retrieve mask... (2)
	AND px_col				; extract active colour bits (4*)
	ORA fw_cbyt				; ...adding new pixel (4*)
	STA (cio_pt), Y			; EEEEEEEEK (6+6)
	RTS
.endproc

.proc _drawRect:near
    ; Load x coord
    LDY #$04
    LDA (sp), Y
    
    ; Load y coord
    LDY #$03
    LDA (sp), Y
    
    ; Load color
    LDY #$00
    LDA (sp), Y
    
    ; Load height
    LDY #$01
    LDA (sp), Y

    ; Load width
    LDY #$02
    LDA (sp), Y
    

    ; Remove args from stack
    JSR incsp5
    RTS
.endproc

.proc _drawFillRect:near
    ; Load x coord
    LDY #$04
    LDA (sp), Y
	STA X_COORD
	
    ; Load y coord
    LDY #$03
    LDA (sp), Y
    STA Y_COORD
	
    ; Load color
;	LDY #$00
	LDA (sp)				; CMOS does not need ,Y
	STA COLOUR
    
    ; Load height
    LDY #$01
    LDA (sp), Y
	STA HEIGHT
	
    ; Load width
    LDY #$02
    LDA (sp), Y
    STA WIDTH

	JSR fill_xywh			; must be called as has a few exit points

    ; Remove args from stack... and return to caller
    JMP incsp5

; *** input ***
x1	= X_COORD				; NW corner x coordinate (<128 in colour, <256 in HIRES)
y1	= Y_COORD				; NW corner y coordinate (<128 in colour, <256 in HIRES)
wid	= WIDTH
x2	= WIDTH					; alternatively, width (will be converted into x1,x2 format)
hei = HEIGHT
y2	= HEIGHT				; alternatively, height (will be converted into y1,y2 format)
col	= COLOUR				; pixel colour, in II format (17*index), HIRES expects 0 (black) or $FF (white)

; *** zeropage usage and local variables ***
cio_pt	= VMEM_POINTER		; screen pointer

; *** other variables (not necessarily in zero page) ***
exc		= TEMP1				; flag for incomplete bytes at each side (could be elshewhere) @ $21
tmp		= exc+1				; temporary use (could be elsewhere)
lines	= tmp+1				; raster counter (could be elsewhere)
bytes	= lines+1			; drawn line width (could be elsewhere)
l_ex	= bytes+1			; extra W pixels (id, HIRES only)
r_ex	= l_ex+1			; extra E pixels (id, HIRES only) @ $26

; *** Durango definitions ***
IO8attr= VIDEO_MODE			; compatible IO8lh for setting attributes (d7=HIRES, d6=INVERSE, now d5-d4 include screen block)

; *** interface for (x,y,w,h) format ***
fill_xywh:
	LDA wid
	BEQ exit				; don't draw anything if zero width!
	CLC
	ADC x1
	STA x2					; swap width for East coordinate
	LDA hei
	BEQ exit				; don't draw anything if zero height!
	CLC
	ADC y1
	STA y2					; swap height for South coordinate
; may now compute number of lines and bytes *** (bytes could be done later, as differs from HIRES)
	LDA x1					; lower limit
	LSR						; check odd bit into C
	LDA x2					; higher limit...
	ADC #0					; ...needs one more if lower was odd
	SEC
	SBC x1					; roughly number of pixels
	LSR						; half of that, is bytes
	ROR exc					; E pixel is active, will end at D6 (after second rotation)
	STA bytes
; number of lines is straightforward
	LDA y2
	SEC
	SBC y1
	STA lines				; all OK
; compute NW screen address (once)
	LDA y1					; get North coordinate... (3)
	STA cio_pt+1			; will be operated later
	LDA #0					; this will be stored at cio_pt
	LSR cio_pt+1
	ROR
	LSR cio_pt+1
	ROR						; divide by 4 instead of times 64, already OK for colour (2+5+2+5)
	BIT IO8attr				; check screen mode (4)
		BPL colfill
		BMI hrfill			; jump to HIRES routine
exit:
		RTS
colfill:
	STA cio_pt				; temporary storage
	LDA x1					; get W coordinate
	LSR						; halved
	ROR exc					; this will store W extra pixel at D7
	CLC						; as we don't know previous exc contents
	ADC cio_pt
	STA cio_pt				; LSB ready, the ADD won't cross page
	LDA IO8attr				; get flags... (4)
	AND #$30				; ...for the selected screen... (2)
	ASL						; ...and shift them to final position (2)
	ORA cio_pt+1			; add to MSB (3+3)
	STA cio_pt+1
c_line:
; first draw whole bytes ASAP
		LDA col				; get colour index twice
		LDY bytes			; number of bytes, except odd E
			BEQ c_sete		; only one pixel (E), manage separately
		DEY					; maximum offset
			BEQ c_setw		; only one pixel (W), manage separately
cbytloop:
			STA (cio_pt), Y	; store whole byte
			DEY
			BNE cbytloop	; do not reach zero
c_exc:
; check for extra pixels
		BIT exc				; check uneven bits
		BVS c_setw			; extra at W (or BMI?)
		BMI c_sete			; extra at E (or BVS?)
			STA (cio_pt), Y	; otherwise last byte is full
			BRA c_eok
c_setw:
		AND #$0F			; keep rightmost pixel colour
		STA tmp				; mask is ready
		LDA (cio_pt), Y		; get original screen contents! (Y=0)
		AND #$F0			; filter out right pixel...
		ORA tmp				; ...as we fill it now
		STA (cio_pt), Y
		BIT exc				; unfortunately we must do this, or manage W pixel first
		BPL c_eok			; no extra bit at E (or BVC?)
			LDA col			; in case next filter gets triggered
c_sete:
			LDY bytes		; this is now the proper index!
			AND #$F0		; keep leftmost pixel
			STA tmp			; mask is ready
			LDA (cio_pt), Y	; get original screen contents!
			AND #$0F		; filter out left pixel...
			ORA tmp			; ...as we fill it now
			STA (cio_pt), Y
c_eok:
; advance to next line
		LDA #$40			; OK for colour
		CLC
		ADC cio_pt
		STA cio_pt
		BCC cl_nowrap
			INC cio_pt+1
cl_nowrap:
		DEC lines
		BNE c_line			; repeat for remaining lines
	RTS
; *** HIRES version ***
hrfill:
; finish proper Y-address computation
	LSR cio_pt+1
	ROR						; divide by 8 instead of times 32 in HIRES mode
	STA cio_pt				; temporary storage
	LDA IO8attr				; get flags... (4)
	AND #$30				; ...for the selected screen... (2)
	ASL						; ...and shift them to final position (2)
	ORA cio_pt+1			; add to MSB (3+3)
	STA cio_pt+1
; lines is OK, but both 'bytes' and new l_ex & r_ex values must be recomputed, plus 'exc'
; determine extra EW pixels
	LDA x2
	AND #7					; modulo 8
	STA r_ex				; 0...7 extra E pixels
	CMP #1					; Carry if >0
	ROR exc					; E pixels present, flag will end at D6 (after second rotation)
	LDA x1
	AND #7					; modulo 8
	STA l_ex				; 0...7 extra W pixels
	CMP #1					; Carry if >0
	ROR exc					; W pixels present, flag at D7
; compute bytes
	LDA exc					; get flags...
	ASL						; ...and put W flag into carry
	LDA x2
	SEC
	SBC x1					; QUICK AND DIRTY**********
	LSR
	LSR
	LSR
	STA bytes				; ...give or take
; add X offset
	LDA x1
	LSR
	LSR
	LSR						; NW / 8
	CLC
	ADC cio_pt
	STA cio_pt				; no C is expected
h_line:
; first draw whole bytes ASAP
		LDA col				; get 'colour' value (0=black, $FF=white)
		LDY bytes			; number of bytes, except extra E
			BEQ h_sete		; only extra E pixels, manage separately
		DEY					; maximum offset
			BEQ h_setw		; only extra W pixels, manage separately
hbytloop:
			STA (cio_pt), Y	; store whole byte
			DEY
			BNE hbytloop	; do not reach zero
h_exc:
; check for extra pixels
		BIT exc				; check uneven bits
		BVS h_setw			; extra at W (or BMI?)
		BMI h_sete			; extra at E (or BVS?)
			STA (cio_pt), Y	; otherwise last byte is full
			BRA h_eok
h_setw:
		LDX l_ex			; get mask index
		AND w_mask, X		; keep rightmost pixels
		STA tmp				; mask is ready
		LDA w_mask, X		; get mask again...
		EOR #$FF			; ...inverted
		AND (cio_pt), Y		; extract original screen intact pixels... (Y=0)
		ORA tmp				; ...as we add the remaining ones now
		STA (cio_pt), Y
		BIT exc				; unfortunately we must do this, or manage W pixel first
		BPL h_eok			; no extra bit at E (or BVC?)
			LDA col			; in case next filter gets triggered
h_sete:
			LDY bytes		; this is now the proper index!
			AND e_mask, X	; keep leftmost pixels
			STA tmp			; mask is ready
			LDA e_mask, X	; get mask again...
			EOR #$FF		; ...inverted
			AND (cio_pt), Y	; extract original screen intact pixels... (Y=0)
			ORA tmp			; ...as we add the remaining ones now
			STA (cio_pt), Y
h_eok:
; advance to next line
		LDA #$20			; OK for HIRES
		CLC
		ADC cio_pt
		STA cio_pt
		BCC hl_nowrap
			INC cio_pt+1
hl_nowrap:
		DEC lines
		BNE h_line			; repeat for remaining lines
	RTS
.endproc

.proc _drawLine:near
    ; Load x coord
    LDY #$04
    LDA (sp), Y
	STA X_COORD
    
    ; Load y coord
    LDY #$03
    LDA (sp), Y
	STA Y_COORD
    
    ; Load color			; just transmitted to _drawPixel
;	LDY #$00
	LDA (sp)				; CMOS does not need , Y
	STA COLOUR
    
    ; Load y2
    LDY #$01
    LDA (sp), Y
	STA HEIGHT				; actually y2

    ; Load x2
    LDY #$02
    LDA (sp), Y
	STA WIDTH				; actually x2
    
; *** input *** placeholder addresses
x1		= X_COORD			; NW corner x coordinate (<128 in colour, <256 in HIRES)
y1		= Y_COORD			; NW corner y coordinate (<128 in colour, <256 in HIRES)
x2		= WIDTH				; _not included_ SE corner x coordinate (<128 in colour, <256 in HIRES) *** reusing variable for convenience
y2		= HEIGHT			; _not included_ SE corner y coordinate (<128 in colour, <256 in HIRES) *** reusing variable for convenience
;px_col	= COLOUR			; pixel colour, in II format (17*index), HIRES expects 0 (black) or $FF (white) *** not used here, just passed to PLOT

; *** zeropage usage and local variables *** beware of conflicts with PLOT (TEMP1 is used!)
sx		= TEMP2				; local variable @ $22
sy		= sx+1				; @ $23
dx		= sy+1				; this is ALWAYS positive... @ $24
dy		= dx+1				; ...but this one is negative OR zero @ $25-26
error	= dy+2				; colour mode cannot be over 254, but 16-bit arithmetic needed @ $27-28
err_2	= error+2			; make room for this! @ $29-2A

dxline:
; compute dx, sx
	LDX #1					; temporary sx
	LDA x2
	SEC
	SBC x1					; this is NOT abs(x1-x0) yet...
	BCS set_sx				; if x0>x1...
		LDX #$FF			; sx=-1, else sx=1
		EOR #$FF			; ...and compute ABS(x1-x0) from x1-x0
		INC					; CMOS only, could use ADC #1 as C known to be clear
set_sx:
	STX sx
	STA dx
; compute dy, sy
	LDY #1					; temporary sy
	LDA y2
	LDX #$FF				; usual final dy sign!
	CMP y1					; if dy=0...
	BNE ne_dy
		INX					; ...MSB is 0 (positive)
ne_dy:
	SEC
	SBC y1					; this is NOT -abs(y1-y0) yet...
	BCS set_sy				; if y0>y1...
		LDY #$FF			; sy=-1, else sy=1
		EOR #$FF			; ...and compute ABS(y1-y0) from y1-y0
		INC					; CMOS only, could use ADC #1 as C known to be clear
set_sy:
	STY sy
	STA dy
; dy = -dy
	SEC
	LDA #0
	SBC dy
	STA dy
	STX dy+1				; definitive sign, previously computed EEEEEEEK
; compute error = dx + dy
	CLC
	ADC dx
	STA error				; error=dx+dy
	TXA						; was dy.h
	ADC #0					; dx ALWAYS positive
	STA error+1				; MSB, just in case
l_loop:
		LDX x1				; *** remove these if dxplot label is NOT accessible ***
		LDY y1
		JSR _drawPixel::dxplot	; *** call primitive with X/Y, assume colours already set *** or use standard procedure, parameters already set
		LDA x1
		CMP x2				; if x0==x1...
		BNE l_cont
			LDA y1			; ...and y1==y0...
			CMP y2
			BEQ l_end		; break
l_cont:
		LDA error
		ASL 				; e2=2*error
		STA err_2
		LDA error+1
		ROL
		STA err_2+1
; compute 16-bit signed difference
		SEC
		LDA err_2
		SBC dy				; don't care about result, just look for the sign on MSB
		LDA err_2+1
		SBC dy+1
; if e2<dy, N is set
		BMI if_x
then_y:						; *** do this if e2 >= dy ***
			LDX x1
			CPX x2
			BEQ if_x		; if x0==x1 break
				LDA error
				CLC
				ADC dy
				STA error	; error += dy
				LDA error+1
				ADC dy+1
				STA error+1	; MSB too EEEEEK
				LDA x1
				CLC
				ADC sx
				STA x1		; x0 += sx
if_x:
; compute 16-bit signed difference
		SEC
		LDA dx
		SBC err_2			; don't care about result, just look for the sign on MSB
		LDA #0				; dx ALWAYS positive
		SBC err_2+1
; if dx<e2, N is set -- that means if e2<=dx, N is clear
		BMI l_loop
then_x:						; *** do this if e2 <= dx ***
			LDX y1
			CPX y2
			BEQ l_loop		; if y0==y1 break
		LDA error
		CLC
		ADC dx
		STA error			; error += dx
		LDA error+1
		ADC #0				; dx ALWAYS positive
		STA error+1			; MSB too EEEEEK
		LDA y1
		CLC
		ADC sy
		STA y1				; y0 += sy
		BRA l_loop
l_end:
    ; Remove args from stack... and return to caller
    JMP incsp5
.endproc


.proc _drawCircle: near
	; Load x coord
    LDY #$03
    LDA (sp), Y
	STA X_COORD
    
    ; Load y coord
    LDY #$02
    LDA (sp), Y
	STA Y_COORD

	; Load radius
    LDY #$01
    LDA (sp), Y
	STA WIDTH				; reasonable usage

	; Load colour
;    LDY #$00
    LDA (sp)				; CMOS doesn't need the , Y
	STA COLOUR				; actually used by _drawPixel

; *** input ***
x0		= X_COORD			; center x coordinate (<128 in colour, <256 in HIRES)
y0		= Y_COORD			; center y coordinate (<128 in colour, <256 in HIRES)
radius	= WIDTH				; circle radius (<128 in colour, <256 in HIRES)
px_col	= COLOUR			; pixel colour, in II format (17*index), HIRES expects 0 (black) or $FF (white), actually zpar

; *** zeropage usage and local variables *** beware of conflicts with PLOT (TEMP1 is used!)
f		= TEMP2				; 16-bit @$22-23
ddf_x	= f+2				; maybe 8 bit is OK? seems always positive @$24-25
ddf_y	= ddf_x+2			; starts negative and gets added to f, thus 16-bit @$26-27
x_coord		= ddf_y+2			; seems 8 bit @$28
y_coord		= x_coord+1				; 8-bit as well @$29

dxcircle:
; compute initial f = 1 - radius
	LDA #1
	SEC
	SBC radius
	STA f					; LSB OK
	LDA #0
	SBC #0
	STA f+1					; sign extention
; ddF_x = 0
	STZ ddf_x
	STZ ddf_x+1
; compute ddF_y = -2 * radius
	STZ ddf_y+1				; clear MSB for a while
	LDA radius
	ASL						; times two
	STA ddf_y				; temporary positive LSB
	ROL ddf_y+1
	LDA #0
	SEC
	SBC ddf_y				; negate
	STA ddf_y
	LDA #0
	SBC ddf_y+1
	STA ddf_y+1				; surely there's a much faster way, but...
; reset x & y
	STZ x_coord
	LDA radius
	STA y_coord
; draw initial dots
;	LDA radius				; already there!
	CLC
	ADC y0
	TAY
	LDX x0
	JSR _drawPixel::dxplot				; plot(x0, y0+radius)
	LDA y0
	SEC
	SBC radius
	TAY
	LDX x0
	JSR _drawPixel::dxplot				; plot(x0, y0-radius)
	LDY y0
	LDA x0
	CLC
	ADC radius
	TAX
	JSR _drawPixel::dxplot				; plot(x0+radius, y0)
	LDY y0
	LDA x0
	SEC
	SBC radius
	TAX
	JSR _drawPixel::dxplot				; plot(x0-radius, y0)
; main loop while x < y
loop:
	LDA x_coord
	CMP y_coord
	BCC c_cont
	JMP c_end				; if x >= y, exit
c_cont:
; if f >= 0... means MSB is positive
		BIT f+1
		BMI f_neg
			DEC y_coord
			LDA ddf_y		; add 2 to ddF_y
			CLC
			ADC #2
			STA ddf_y
			TAY				; convenient LSB storage
			LDA ddf_y+1
			ADC #0
			STA ddf_y+1
			TAX				; convenient MSB storage...
			TYA				; ...for adding ddF_y to f
			CLC
			ADC f
			STA f
			TXA
			ADC f+1
			STA f+1
f_neg:
		INC x_coord
		LDA ddf_x			; add 2 to ddF_x
		CLC
		ADC #2
		STA ddf_x
		TAY					; again, convenient storage...
		LDA ddf_x+1
		ADC #0
		STA ddf_x+1
		TAX
		TYA					; ...for adding ddF_x to f...
		SEC					; ...plus 1!
		ADC f
		STA f
		TXA
		ADC f+1
		STA f+1
; do 8 plots per iteration
	LDA x0
	CLC
	ADC x_coord
	TAX
	LDA y0
	CLC
	ADC y_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0+x, y0+y)
	LDA x0
	SEC
	SBC x_coord
	TAX
	LDA y0
	CLC
	ADC y_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0-x, y0+y)
	LDA x0
	CLC
	ADC x_coord
	TAX
	LDA y0
	SEC
	SBC y_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0+x, y0-y)
	LDA x0
	SEC
	SBC x_coord
	TAX
	LDA y0
	SEC
	SBC y_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0-x, y0-y)
	LDA x0
	CLC
	ADC y_coord
	TAX
	LDA y0
	CLC
	ADC x_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0+y, y0+x)
	LDA x0
	SEC
	SBC y_coord
	TAX
	LDA y0
	CLC
	ADC x_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0-y, y0+x)
	LDA x0
	CLC
	ADC y_coord
	TAX
	LDA y0
	SEC
	SBC x_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0+y, y0-x)
	LDA x0
	SEC
	SBC y_coord
	TAX
	LDA y0
	SEC
	SBC x_coord
	TAY
	JSR _drawPixel::dxplot				; plot(x0-y, y0-x)
	JMP loop
c_end:
	RTS
	; Remove args from stack
	JMP incsp4
.endproc

; *** data ***
; _drawPixel
pixtab:
	.byt	128, 64, 32, 16, 8, 4, 2, 1		; bit patterns from offset

; _drawFillRect
e_mask:
	.byt	0, %10000000, %11000000, %11100000, %11110000, %11111000, %11111100, %11111110	; [0] never used
w_mask:
	.byt	0, %00000001, %00000011, %00000111, %00001111, %00011111, %00111111, %01111111	; [0] never used
