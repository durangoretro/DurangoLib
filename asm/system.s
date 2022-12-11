; ---------------------------------------------------------------------------
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------

.include "durango_hw.inc"
.include "crt0.inc"
.PC02

.importzp  sp

.export _setHiRes
.export _getChar

.segment "LIB"

.proc _setHiRes: near
	CMP #0
	BNE hires
	LDA VIDEO_MODE
	AND #%01111111
	STA VIDEO_MODE
	BRA end
	hires:
	LDA VIDEO_MODE
	ORA #%10000000
	STA VIDEO_MODE
	end:
	RTS
.endproc

.proc _getChar: near
	read:
	LDA KEY_PRESSED
	BEQ read
	STZ KEY_PRESSED
	rts
.endproc
