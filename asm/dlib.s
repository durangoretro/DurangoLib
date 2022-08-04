.import incsp3
.importzp  sp

.export _setVideoMode
.export _drawPixelPair

.zeropage
_screen_pointer: .res 2, $00 ;  Reserve a local zero page pointer for screen position


.segment "CODE"

.proc _setVideoMode: near
    STA $df80
    RTS
.endproc

.proc _drawPixelPair: near
	; Initialize screen position
    LDA #$60
    STA _screen_pointer+1
    LDA #$00
    STA _screen_pointer
        
    convert_coords_to_mem:
    LDX #$00
    ; Load y coord argument in acumulator
    LDY #$01
    LDA (sp), Y
    ; Multiply y coord by 64 (64 bytes each row)
    ASL
    ; Also shift more sig byte
    TAY
    TXA
    ROL
    TAX
    TYA
    ; Shift less sig byte
    ASL
    ; Also shift more sig byte
    TAY
    TXA
    ROL
    TAX
    TYA
    ; Shift less sig byte
    ASL
    ; Also shift more sig byte
    TAY
    TXA
    ROL
    TAX
    TYA
    ; Shift less sig byte
    ASL
    ; Also shift more sig byte
    TAY
    TXA
    ROL
    TAX
    TYA
    ; Shift less sig byte
    ASL
    ; Also shift more sig byte
    TAY
    TXA
    ROL
    TAX
    TYA
    ; Shift less sig byte
    ASL
    ; Also shift more sig byte
    TAY
    TXA
    ROL
    TAX
    TYA
    ; Shift less sig byte
    ; Add to initial memory address, and save it
    CLC
    ADC _screen_pointer
    STA _screen_pointer

    ; If overflow, add one to more sig byte
    BCC conv_coor_mem_01
    INX
    conv_coor_mem_01:
    ; Add calculated offset to $11 (more sig)
    TXA
    CLC
    ADC _screen_pointer+1
    STA _screen_pointer+1

    ; Calculate X coord
    ; Load y coord
    LDY #$02
    LDA (sp), Y
    ; Divide x coord by 2 (2 pixel each byte)
    LSR
    ; Add to memory address
    CLC
    ADC _screen_pointer
    ; Store in video memory position
    STA _screen_pointer
    ; If overflow, increment left byte
    BCC conv_coor_mem_02
    INC _screen_pointer+1
    conv_coor_mem_02:
    ; Store color in accumulator
    LDY #$00
    LDA (sp), Y
    ; Draw actual pixel
    LDY #$00
    STA (_screen_pointer), Y

	; Remove args from stack
	JSR incsp3

	RTS
.endproc


