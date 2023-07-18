.INCLUDE "durango_constants.inc"
.PC02

.importzp sp
.import incsp1
.import coords2mem

.export _playMelody

.segment  "CODE"


.proc _playMelody: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    JMP tocar_melodia
.endproc


.proc tocar_melodia: near
    SEI
    loop:
    LDY #0
    LDA (DATA_POINTER),Y
    BMI end
    STA Y_COORD
    INY
    LDA (DATA_POINTER),Y
    STA X_COORD

    JSR LAB_BEEP

    INC DATA_POINTER
    INC DATA_POINTER
    BNE skip
    INC DATA_POINTER+1
    skip:
    BRA loop
    end:
    CLI
    RTS
.endproc

; Music lib by Carlos J. Santisteban

; duración notas (para negra~120/minuto)
; redonda	= 128
; blanca	= 64
; negra		= 32
; corchea	= 16
; semicor.	= 8
; fusa		= 4
; semifusa	= 2

; perform BEEP d,n (len/25, note 0=F3 ~ 42=B6 (ZX Spectrum value+7))
.proc LAB_BEEP: near
	; Nota en X
    LDX Y_COORD
    ; Periodo onda
    LDY fr_Tab, X		; period
	; Factor ajuste
    LDA cy_Tab, X		; base cycles
	STA X2_COORD		; eeek
	; Periodo en A
    TYA
    BEQ silence
    LAB_BRPT:
	LDX X2_COORD		; retrieve repetitions...
    LAB_BLNG:
	TAY					; ...and period
    LAB_BCYC:
	JSR LAB_BDLY		; waste 12 cyles...
	NOP					; ...and another 2
	DEY
	BNE LAB_BCYC		; total 19t per iteration
	DEX
	STX IOBEEP			; toggle speaker
	BNE LAB_BLNG
	DEC X_COORD			; repeat until desired length
	BNE LAB_BRPT
    LAB_BDLY:
	RTS
    silence:
    LDA #77
    LAB_BRPTS:
	LDX X2_COORD		; retrieve repetitions...
    LAB_BLNGS:
	TAY					; ...and period
    LAB_BCYCS:
	JSR LAB_BDLYS		; waste 12 cyles...
	NOP					; ...and another 2
	DEY
	BNE LAB_BCYCS		; total 19t per iteration
	DEX
	STZ IOBEEP			; toggle speaker
	BNE LAB_BLNGS
	DEC X_COORD			; repeat until desired length
	BNE LAB_BRPTS
    LAB_BDLYS:
	RTS
.endproc


; *** Durango-X BEEP specific, table of notes and cycles ***
fr_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byte						232,219,206,195,184,173,164		; octave 3
	.byte	155,146,138,130,123,116,109,103, 97, 92, 87, 82		; octave 4
	.byte   77, 73, 69, 65, 61, 58, 55, 52, 49, 46, 43, 41		; octave 5
	.byte	39, 36, 34, 32, 31, 29, 27, 26, 24, 23, 22, 20		; octave 6
    .byte   0
	
cy_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B		repetitions for a normalised 20 ms length
	.byte						  6,  8,  8,  8,  8, 10, 10		; octave 3
	.byte	 10, 12, 12, 12, 14, 14, 14, 16, 16, 18, 18, 20		; octave 4
	.byte	 20, 22, 24, 24, 26, 28, 30, 30, 32, 34, 38, 38		; octave 5
	.byte	 40, 44, 46, 50, 52, 56, 58, 60, 66, 68, 72, 78		; octave 6
    .byte    20

