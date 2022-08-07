.import incsp3
.import incsp5
.importzp  sp

.export _setVideoMode
.export _drawPixelPair
.export _waitVsync
.export _waitFrames
.export _fillScreen
.export _consoleLogHex
.export _consoleLogChar
.export _consoleLogStr
.export _drawRect
.export _readGamepad1
.export _readGamepad2

.bss
_xcoord: .byt $00
_ycoord: .byt $00
_current_color: .byt $00
_temp1: .byt $00

.zeropage
_screen_pointer: .res 2, $00 ;  Reserve a local zero page pointer for screen position
_data_pointer: .res 2, $00 ;  Reserve a local zero page pointer for data position


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
    ; Load x coord
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
	; Get data pointer from procedure args
    STA _data_pointer
    STX _data_pointer+1
	; Set virtual serial port in ascii mode
	LDA #$01
	STA $df94
	; Iterator
	LDY #$00
	loop:
	LDA (_data_pointer),Y
	BEQ end
	STA $df93
	INY
	BNE loop
	end:
    RTS
.endproc

; Converts x,y coord into memory pointer.
; _xcoord, _ycoord pixel coords
; _screen_pointer _screen_pointer+1 current video memory pointer
.proc _convert_coords_to_mem:near
    ; Init video pointer
    LDA #$60
    STA _screen_pointer+1
    LDA #$00
    STA _screen_pointer
    ; Clear X reg
    LDX #$00
    ; Multiply y coord by 64 (64 bytes each row)
    LDA _ycoord
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
    ; Add calculated offset to _screen_pointer+1 (more sig)
    TXA
    CLC
    ADC _screen_pointer+1
    STA _screen_pointer+1

    ; Calculate X coord
    ; Divide x coord by 2 (2 pixel each byte)
    LDA _xcoord
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
    RTS
.endproc

.proc _drawRect:near
    ; Load x coord
    LDY #$04
    LDA (sp), Y
    STA _xcoord
    ; Load y coord
    LDY #$03
    LDA (sp), Y
    STA _ycoord
    ; Load color
    LDY #$00
    LDA (sp), Y
    STA _current_color
    ; Convert to mem pointer
    JSR _convert_coords_to_mem
    ; Store height temporaly in data_pointer
    LDY #$01
    LDA (sp), Y
    STA _data_pointer
    ; Store width temporaly in data_pointer+1
    LDY #$02
    LDA (sp), Y
    STA _data_pointer+1

    ; Load height in x
    LDX _data_pointer
    paint_row:
    ; Divide width by 2
    LDA _data_pointer+1
    LSR
    ; Store it in Y
    TAY
    ; Load current color in A
    LDA _current_color
    ; Draw as many pixels as Y register says
    paint:
    STA (_screen_pointer), Y
    DEY
    BNE paint
    STA (_screen_pointer), Y
    ; Next row
    LDA _screen_pointer
    CLC
    ADC #$40
    STA _screen_pointer
    BCC skip_upper
    INC _screen_pointer+1
    skip_upper:
    DEX
    BNE paint_row

    ; Remove args from stack
    JSR incsp5
    RTS
.endproc

.proc _readGamepad1:near
    ; 1. write into $DF9C
    STA $DF9C
    ; 2. write into $DF9D 8 times
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    ; 3. read first controller
    LDA $DF9C
    RTS
.endproc

.proc _readGamepad2:near
    ; 1. write into $DF9C
    STA $DF9C
    ; 2. write into $DF9D 8 times
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    STA $DF9D
    ; 3. read second controller
    LDA $DF9D
    RTS
.endproc

.proc _drawPixel: near
    ; Load x coord
    LDY #$02
    LDA (sp), Y
    STA _xcoord
    ; Load y coord
    LDY #$01
    LDA (sp), Y
    STA _ycoord
    ; Load color
    LDY #$00
    LDA (sp), Y
    STA _current_color
    
    ; Check if left or right pixel
    LDA _xcoord
    ROR
    PHP
    BCC left
    right:
    LDX _xcoord
    DEX
    STX _xcoord
    LDA #$0F
    STA _temp1
    LDA _current_color
    AND _temp1
    STA _current_color
    CLC
    BCC paint
    left:
    LDA #$F0
    STA _temp1
    LDA _current_color
    AND _temp1
    STA _current_color
    paint:
    ; Convert to mem pointer
    JSR _convert_coords_to_mem
    
    
    ; Draw actual pixel
    LDY #$00
    STA (_screen_pointer), Y

    ; Remove args from stack
    JSR incsp3
    RTS
.endproc

