.include "durango_constants.inc"
.PC02

.importzp  sp
.import incsp4

.export _conio_init
.export _set_font
.export _printf

.proc  _conio_init: near    
    RTS
.endproc

.proc _set_font: near
    ; Font pointer
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    
    RTS
.endproc

.proc  _printf: near
    RTS
.endproc

; Print constant string
.proc _printstr: near
    ; Get data pointer from procedure args
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Iterator
    LDY #$00
    loop:
    LDA (DATA_POINTER),Y
    BEQ end
    ; Current char in A
    PHY
    JSR conio
    PLY
    INY
    BNE loop
    end:
    
    RTS
.endproc


; A = 0 -> INPUT
; A > 0 -> OUTPUT
.proc conio: near
    RTS
.endproc
