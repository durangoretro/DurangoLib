.import incsp3
.importzp  sp

.export _setVideoMode
.export _drawPixelPair
.export _waitVsync
.export _waitFrames
.export _fillScreen
.export _consoleLogHex
.export _consoleLogChar
.export _consoleLogStr

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

; Wait for vsync.
.proc _waitVsync: near
    wait_loop:
    BIT $DF88
    BVC wait_loop
    RTS
.endproc

.proc _waitFrames: near
	TAX
	wait_vsync_end:
    BIT $DF88
    BVS wait_vsync_end
	wait_vsync_begin:
    BIT $DF88
    BVC wait_vsync_begin   
    DEX
    BNE wait_vsync_end
	RTS
.endproc

.proc _fillScreen: near
	; Init video pointer
    LDX #$60
    STX _screen_pointer+1
    LDX #$00
    STX _screen_pointer
	TAX
loop2:
	TXA
	; Iterate over less significative memory address
    LDY #$00
loop:
    STA (_screen_pointer), Y
    INY
    BNE loop

    ; Iterate over more significative memory address
    INC _screen_pointer+1 ; Increment memory pointer Hi address
	LDA #$80 ; Compare with end memory position
	CMP _screen_pointer+1
    BNE loop2
    RTS
.endproc

.proc  _consoleLogHex: near
    ; Set virtual serial port in hex mode
	LDX #$00
	STX $df94
	; Send value to virtual serial port
	STA $df93
	RTS
.endproc

.proc  _consoleLogChar: near
    ; Set virtual serial port in ascii mode
	LDX #$01
	STX $df94
	; Send value to virtual serial port
	STA $df93
	RTS
.endproc

.proc  _consoleLogStr: near
    RTS
.endproc
