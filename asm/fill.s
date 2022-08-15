; Durango-X filled rectangle routine
; (c) 2022 Carlos J. Santisteban
; last modified 20220815-1755

; *** input *** presumed offsets from (SP)

x1	= 5						; NW corner x coordinate (<128 in colour, <256 in HIRES), but all NW/NE/SW/SE combos are accepted
y1	= 4						; NW corner y coordinate (<128 in colour, <256 in HIRES), but all NW/NE/SW/SE combos are accepted
x2	= 3						; _not included_ SE corner x coordinate (<128 in colour, <256 in HIRES), but all NW/NE/SW/SE combos are accepted
y2	= 2						; _not included_ SE corner y coordinate (<128 in colour, <256 in HIRES), but all NW/NE/SW/SE combos are accepted
col	= 1						; pixel colour, in II format (17*index), ignored in HIRES

; *** zeropage usage and local variables ***
	*	= $E4				; *** placeholder (local1) ***

cio_pt:	.word	0			; screen pointer (may reuse from CONIO)

; *** other variables (not necessarily in zero page) ***
exc:	.byt	0			; flag for incomplete bytes at each side (could be elshewhere)
tmp:	.byt	0			; temporary use (could be elsewhere)
lines:	.byt	0			; raster counter (could be elsewhere)
bytes:	.byt	0			; drawn line width (could be elsewhere)

; *** Durango definitions ***
-IO8attr= $DF80				; compatible IO8lh for setting attributes (d7=HIRES, d6=INVERSE, now d5-d4 include screen block)

.text
	*	= $F000				; *** placeholder ***

filled:
; first of all, check whether coordinates are inverted in any way, to get them sorted as NW-SE
	LDY #x2					; should be W
	LDA (SP), Y
	LDY #x1					; thus less than E
	CMP (SP), Y
	BEQ exit				; don't draw anything if zero width!
	BCS x_ok
		TAX					; otherwise, swap x1-x2, keep older x2
		LDA (SP), Y			; get x1
		LDY #x2
		STA (SP), Y			; set x2 as older x1
		TXA					; retrieve older x2
		LDY #x1
		STA (SP), Y			; store older x2 value into x1
x_ok:
	LDY #y2					; should be S
	LDA (SP), Y
	LDY #y1					; thus less than N
	CMP (SP), Y
	BEQ exit				; don't draw anything if zero height!
	BCS y_ok
		TAX					; otherwise, swap y1-y2, keep older y2
		LDA (SP), Y			; get y1
		LDY #y2
		STA (SP), Y			; set y2 as older y1
		TXA					; retrieve older y2
		LDY #y1
		STA (SP), Y			; store older y2 value into y1
y_ok:
; may now compute number of lines and bytes
	LDY #x1					; lower limit
	LDA (SP), Y
	LSR						; check odd bit into C
	LDY #x2					; higher limit...
	LDA (SP), Y
	ADC #0					; ...needs one more if lower was odd
	SEC
	LDY #x1					; roughly number of pixels
	SBC (SP), Y
	LSR						; half of that, is bytes
	ROR exc					; E pixel is active, will end at D6 (after second rotation)
	STA bytes
; number of lines is straightforward
	LDY #y2
	LDA (SP), Y
	SEC
	LDY #y1
	SBC (SP), Y
	STA lines				; all OK
; compute NW screen address (once)
	LDY #y1					; get North coordinate... (3)
	LDA (SP), Y
	STA cio_pt+1			; will be operated later
	LDA #0					; this will be stored at cio_pt
	LSR cio_pt+1
	ROR
	LSR cio_pt+1
	ROR						; divide by 4 instead of times 64, already OK for colour (2+5+2+5)
	BIT IO8attr				; check screen mode (4)
	BPL colfill				; * HIRES (TBD) below * (3/2 for COLOUR/HIRES)
;		JMP hrfill			; jump to HIRES routine (TBD)
exit:
	RTS
colfill:
	STA cio_pt				; temporary storage
	LDY #x1					; get W coordinate
	LDA (SP), Y
	LSR						; halved
	ROR exc					; this will store W extra pixel at D7
	CLC						; as we don't know previous exc contents
	ADC cio_pt
	STA cio_pt				; LSB ready, the ADD won't cross page
	LDA _draw_buffer		; get screen... (4)
;	AND #$30				; ...for the selected screen... (2)
;	ASL						; ...and shift them to final position (2)
	ORA cio_pt+1			; add to MSB (3+3)
	STA cio_pt+1
c_line:
; first draw whole bytes ASAP
		LDY #col			; get colour index twice *** might use local copy
		LDA (SP), Y
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
			LDY #col		; in case next filter gets triggered *** might use local copy
			LDA (SP), Y
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
;		BIT IO8attr			; check mode
;		BPL nx_lin
;			LSR				; HIRES adds just $20
;nx_lin:
		CLC
		ADC cio_pt
		STA cio_pt
		BCC cl_nowrap
			INC cio_pt+1
cl_nowrap:
		DEC lines
		BNE c_line			; repeat for remaining lines
	RTS
