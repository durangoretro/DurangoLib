; ---------------------------------------------------------------------------
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------

.include "durango_hw.inc"
.include "crt0.inc"
.PC02

.export _consoleLogHex

VSP_HEX = $F0

.proc  _consoleLogHex: near
    ; Set virtual serial port in hex mode
    LDX #VSP_HEX
	STX VSP_CONFIG
    ; Send value to virtual serial port
    STA VSP
    RTS
.endproc
