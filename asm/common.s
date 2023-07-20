.INCLUDE "durango_constants.inc"
.PC02

.export coords2mem
.export readchar

.segment  "CODE"

.proc coords2mem: near
    ; Calculate Y coord
    STZ VMEM_POINTER
    LDA Y_COORD
    LSR
    ROR VMEM_POINTER
    LSR
    ROR VMEM_POINTER
    ADC #$60
    STA VMEM_POINTER+1
    ; Calculate X coord
    LDA X_COORD
    LSR
    CLC
    ADC VMEM_POINTER
    STA VMEM_POINTER
    BCC skip_upper
    INC VMEM_POINTER+1
    skip_upper:
    RTS
.endproc

.proc readchar: near
    ; Load keyboard status
    LDA KEYBOARD_CACHE
    STA TEMP11    
    LDA KEYBOARD_CACHE+1
    STA TEMP12    
    LDA KEYBOARD_CACHE+2
    STA TEMP13    
    LDA KEYBOARD_CACHE+3
    STA TEMP14    
    LDA KEYBOARD_CACHE+4
    STA TEMP15
    LDX #0
    LDY #40

    loop:
    ; Rotate
    ASL TEMP15
    ROL TEMP14
    ROL TEMP13
    ROL TEMP12
    ROL TEMP11
    BCS end
    INX
    DEY
    BNE loop
    LDA #0
    RTS
    
    end:
    LDA keymap,X
    RTS
.endproc

.segment  "RODATA"

keymap:
; SPACE, INTRO, SHIFT, P,  O,   A,   Q,   1
.byte $20, $0a, $00, $50, $30, $41, $51, $31
;   ALT,    L,   Z,   0,   9,   S,   W,   2
.byte $00, $4c, $5a, $4f, $39, $53, $57, $32
;      M,   K,   X,   I,  8,    D,   E,   3
.byte $4d, $4b, $58, $49, $38, $44, $45, $33
;      N,   J,   C,   U,   7,   F,   R,   4
.byte $4e, $4a, $43, $55, $37, $46, $52, $34
;      B,   H,   V,   Y,   6,   G,   T,   5
.byte $42, $48, $56, $59, $36, $47, $54, $35
