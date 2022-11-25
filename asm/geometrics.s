.include "durango_hw.inc"
.include "crt0.inc"
.PC02

.export _fillScreen
.export _drawPixel

.import incsp3
.importzp  sp

.proc _fillScreen: near
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



; *** data ***
; _drawPixel
pixtab:
	.byt	128, 64, 32, 16, 8, 4, 2, 1		; bit patterns from offset
