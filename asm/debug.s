; ---------------------------------------------------------------------------
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------

.include "durango_hw.inc"
.include "crt0.inc"
.PC02

.export _consoleLogHex
.export _consoleLogWord
.export _consoleLogBinary
.export _consoleLogDecimal
.export _consoleLogChar
.export _consoleLogStr
.export _startStopwatch
.export _stopStopwatch

VSP_HEX = $F0
VSP_ASCII = $F1
VSP_BINARY = $F2
VSP_DECIMAL = $F3
VSP_STOPWATCH_START = $FB
VSP_STOPWATCH_STOP = $FC
VSP_DUMP = $FD
VSP_STACK = $FE
VSP_STAT = $FF

.proc  _consoleLogHex: near
    ; Set virtual serial port in hex mode
    LDX #VSP_HEX
	STX VSP_CONFIG
    ; Send value to virtual serial port
    STA VSP
    RTS
.endproc

.proc  _consoleLogWord: near
    ; Set virtual serial port in hex mode
    LDY #VSP_HEX
	STY VSP_CONFIG
    ; Send value to virtual serial port
    STA VSP
    STX VSP
    RTS
.endproc

.proc  _consoleLogBinary: near
    ; Set virtual serial port in hex mode
    LDX #VSP_BINARY
	STX VSP_CONFIG
    ; Send value to virtual serial port
    STA VSP
    RTS
.endproc

.proc  _consoleLogDecimal: near
    ; Set virtual serial port in hex mode
    LDX #VSP_DECIMAL
	STX VSP_CONFIG
    ; Send value to virtual serial port
    STA VSP
    RTS
.endproc

.proc  _consoleLogChar: near
    ; Set virtual serial port in ascii mode
    LDX #VSP_ASCII
    STX VSP_CONFIG
    ; Send value to virtual serial port
    STA VSP
    RTS
.endproc

.proc  _consoleLogStr: near
    ; Get data pointer from procedure args
    STA DATA_POINTER
    STX DATA_POINTER+1
    ; Set virtual serial port in ascii mode
    LDA #VSP_ASCII
    STA VSP_CONFIG
    ; Iterator
    LDY #$00
    loop:
    LDA (DATA_POINTER),Y
    BEQ end
    STA VSP
    INY
    BNE loop
    end:
    RTS
.endproc

.proc _startStopwatch: near
    LDA #VSP_STOPWATCH_START
    STA VSP_CONFIG
    RTS
.endproc

.proc _stopStopwatch: near
    LDA #VSP_STOPWATCH_STOP
    STA VSP_CONFIG
    RTS
.endproc
