.import incsp3
.import incsp5
.importzp  sp

.exportzp _screen_pointer
.exportzp _data_pointer

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
.export _drawPixel
.export _disableDoubleBuffer
.export _enableDoubleBuffer
.export _swapBuffers

.bss
_draw_buffer: .byt $00
_display_buffer: .byt $00
_xcoord: .byt $00
_ycoord: .byt $00
_current_color: .byt $00
_temp1: .byt $00
_temp2: .byt $00

.zeropage
_screen_pointer: .res 3, $00 ;  Reserve a local zero page pointer for screen position
_data_pointer: .res 2, $00 ;  Reserve a local zero page pointer for data position


.CODE

.proc _setVideoMode: near
    STA $df80
    RTS
.endproc

.proc _drawPixelPair: near
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
    
    ; Convert to mem pointer
    JSR _convert_coords_to_mem
    
    ; Store color in accumulator
    LDA _current_color
    ; Draw actual pixel
    STA (_screen_pointer)

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
	PHA
	; Init video pointer
    LDX _draw_buffer
    LDY #$00
    STY _screen_pointer
    TXA
    CLC
    ADC #$20	; compute end address
    STA _temp1
    PLA
	; Calculate end memory position into temp1
loop2:
    STX _screen_pointer+1
	; Iterate over less significative memory address
loop:
    STA (_screen_pointer), Y
    INY
    BNE loop

    ; Iterate over more significative memory address
    INX ; Increment memory pointer Hi address
    CPX _temp1
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
    ; Clear X reg
    LDX #$00
    ; Clear _screen_pointer
    STX _screen_pointer
    ; Multiply y coord by 64 (64 bytes each row)
    LDA _ycoord
    LSR
    STA _screen_pointer+1
    ROR _screen_pointer
    ; Sencond shift
    LSR _screen_pointer+1
    ROR _screen_pointer
    
    ; Add base memory address
    CLC
    LDA _screen_pointer+1
    ADC _draw_buffer
    STA _screen_pointer+1
    LDA _screen_pointer
    ADC #$00
    STA _screen_pointer
    
    ; Calculate X coord
    ; Divide x coord by 2 (2 pixel each byte)
    LDA _xcoord
    PHA
    ; Check left/right
    AND #$01
    ROR
    ROR
    STA _screen_pointer+2
    PLA
    LSR
    ; Add to memory address
    CLC
    ADC _screen_pointer
    STA _screen_pointer
    LDA _screen_pointer+1
    ADC #$00
    STA _screen_pointer+1
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
    ; Store height temporaly in temp1
    LDY #$01
    LDA (sp), Y
    STA _temp1
    ; Store width temporaly in temp2
    LDY #$02
    LDA (sp), Y
    STA _temp2

    ; Load height in x
    LDX _temp1
    paint_row:
    ; Divide width by 2
    LDA _temp2
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

.proc _drawCurrentPosition: near
    LDY #$00
    LDA _screen_pointer+2
    BMI right
    left:
    ; Clear pixel
    LDA #$0F    
	AND (_screen_pointer), Y
	STA (_screen_pointer), Y
    ; Clear color. Store in X
    LDA _current_color
    AND #$F0
    TAX
    CLC
    BCC endif
    right:
    ; Clear pixel
	LDA #$F0
	AND (_screen_pointer), Y
	STA (_screen_pointer), Y
	; Clear color. Store in X
    LDA _current_color
    AND #$0F
    TAX
	endif:
    ; Draw actual pixel
    TXA
	ORA  (_screen_pointer), Y
    STA (_screen_pointer), Y

    ; Increment pixel
    LDA _screen_pointer+3
    CLC
    ADC #$80
    STA _screen_pointer+3
    LDX _screen_pointer
    INX
    STX _screen_pointer
    BCC end2
    LDX _screen_pointer+1
    INX
    STX _screen_pointer+1
    end2:
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
    
    ; Convert to mem pointer
    JSR _convert_coords_to_mem
        
    ; Draw actual pixel
    JSR _drawCurrentPosition

    ; Remove args from stack
    JSR incsp3
    RTS
.endproc

.proc _disableDoubleBuffer: near
	LDA #$60
	STA _draw_buffer
	STA _display_buffer
	LDA #$3c
	STA $df80
    RTS
.endproc

.proc _enableDoubleBuffer: near
	LDX #$40 ; Draw buffer
	LDY #$60 ; Display buffer
	STX _draw_buffer
	STY _display_buffer
	LDA #$3c
	STA $df80
    RTS
.endproc

.proc _swapBuffers: near
	LDX _display_buffer
	LDY _draw_buffer
	STX _draw_buffer
	STY _display_buffer
	LDA $df80
	AND #$cf
	; If display (Y)==$60
	CPY #$60
	BNE else
	ORA #$30
	CLC
	BCC endif
	else:
	ORA #$20
	endif:
	; Wait for vsync
	BIT $DF88
    BVC endif
	STA $df80
    RTS
.endproc

.proc _drawTilemap: near

	RTS
.endproc

.proc _waitStart: near
	
	RTS
.endproc
