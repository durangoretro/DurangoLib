; Draw procedures
.export _fillScreen
.export _drawRect
.export _drawBall
.export _cleanBall
.export _moveBall
.export _moveRight
.export _moveLeft


; Durango HW constants
SYNC = $DF88
VSP = $df93
VSP_CONFIG = $df94

.zeropage
VMEM_POINTER: .res 2, $00
DATA_POINTER: .res 2, $00
X_COORD: .res 1, $00
Y_COORD: .res 1, $00
TEMP1: .res 1, $00
TEMP2: .res 1, $00


.segment "CODE"
.PC02



; ---- DRAW PROCEDURES ---
.proc _fillScreen: near
    ; Init video pointer
    LDX #$60
    STX VMEM_POINTER+1
    LDY #$00
    STY VMEM_POINTER
    ; Load current color
loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
	INC VMEM_POINTER+1
    BPL loop
    RTS
.endproc

.proc _convert_coords_to_mem: near
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

.proc _drawRect: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; LDA Y_COORD
    LDY #1
    LDA (DATA_POINTER),y
    STA Y_COORD
        
    ;LDA X_COORD
    LDA (DATA_POINTER)
    STA X_COORD
        
    ; Calculate memory position
	JSR _convert_coords_to_mem
    
    ; Write mem position to struct
    LDA VMEM_POINTER
    LDY #2
    STA (DATA_POINTER),y
    LDA VMEM_POINTER+1
    INY
    STA (DATA_POINTER),y
    
    ; Divide width by 2 and store in temp1
	LDY #5
	LDA (DATA_POINTER), Y
    LSR
    STA TEMP1
	
	; Load height in x
	LDY #6
	LDA (DATA_POINTER), Y
	TAX
    
	; Load color in A
	LDY #4
	LDA (DATA_POINTER), Y
    		
	paint_row:
    LDY TEMP1
	; Draw as many pixels as Y register says
    DEY
	paint:
	STA (VMEM_POINTER), Y
	DEY
	BPL paint

	; Next row
	PHA
    LDA VMEM_POINTER
	CLC
	ADC #$40
	STA VMEM_POINTER
	BCC skip_upper
	INC VMEM_POINTER+1
 	skip_upper:
	PLA
    DEX
	BNE paint_row

	RTS
.endproc

.proc _drawBall: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; LDA Y_COORD
    LDY #1
    LDA (DATA_POINTER),Y
    STA Y_COORD
        
    ;LDA X_COORD
    LDA (DATA_POINTER)
    STA X_COORD
        
    ; Calculate memory position
	JSR _convert_coords_to_mem
    
    ; Write mem position to struct
    LDA VMEM_POINTER
    LDY #2
    STA (DATA_POINTER),Y
    LDA VMEM_POINTER+1
    INY
    STA (DATA_POINTER),Y
    
    ; Load color in A
	LDY #4
	LDA (DATA_POINTER),Y
    
    ; Draw ball
    STA (VMEM_POINTER)
    LDY #$40
    STA (VMEM_POINTER),Y
    
    RTS
.endproc

.proc _cleanBall: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Read mem position from struct
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    
    ; Load background color in A
    LDA $7fff
    
    ; Draw ball
    STA (VMEM_POINTER)
    LDY #$40
    STA (VMEM_POINTER),Y
    
    RTS
.endproc

.proc _moveBall: near
    JSR _cleanBall
    LDA DATA_POINTER
    LDX DATA_POINTER+1
    JMP _drawBall
.endproc

; Draw column of solid color 
; VMEM_POINTER: where to draw
; Y: color
; X: height
.proc _drawColumn: near
    loop:
    TYA
    STA (VMEM_POINTER)
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    BCC skip_upper
    INC VMEM_POINTER+1
    skip_upper:
    DEX
    BNE loop
    RTS
.endproc

.proc _moveRight: near
	; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Update VMEM_POINTER
    LDY #2
    LDA (DATA_POINTER), Y
    STA VMEM_POINTER
    PHA
    INY
    LDA (DATA_POINTER), Y
    STA VMEM_POINTER+1
    PHA
        
    ; Divide width by 2 and store in temp1
	LDY #5
	LDA (DATA_POINTER), Y
    LSR
    STA TEMP1
            
    ; Store height in X
	LDY #6
	LDA (DATA_POINTER), Y
    TAX
    
    ; Store background color in Y
    LDY $7fff
                    
    ; Draw left column
    JSR _drawColumn
    
    ; Draw right column
    ; Update VMEM_POINTER
    LDY #2
    LDA (DATA_POINTER), Y
    CLC
    ADC TEMP1
    STA VMEM_POINTER
    INY
    LDA (DATA_POINTER), Y
    STA VMEM_POINTER+1
    ; Store height in X
	LDY #6
	LDA (DATA_POINTER), Y
    TAX
    ; Load color in y
	LDY #4
	LDA (DATA_POINTER), Y
    TAY
    JSR _drawColumn
    
    
    ; Update X coord
    LDA (DATA_POINTER)
    INA
    INA
    STA (DATA_POINTER)    
    
    ; Update VMEM_POINTER
    PLA
    LDY #3
    STA (DATA_POINTER), Y
    PLA
    INA
    DEY
    STA (DATA_POINTER), Y
    
    RTS
.endproc

.proc _moveLeft: near
	; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Update VMEM_POINTER
    LDY #2
    LDA (DATA_POINTER), Y
    DEA
    STA (DATA_POINTER), Y
    STA VMEM_POINTER
    PHA
    INY
    LDA (DATA_POINTER), Y
    STA VMEM_POINTER+1
    PHA
    
    ; Store height in X
	LDY #6
	LDA (DATA_POINTER), Y
    TAX
    
    ; Load color in y
	LDY #4
	LDA (DATA_POINTER), Y
    TAY
    
    ; Draw left column
    JSR _drawColumn
    
    ; Divide width by 2 and store in temp1
	LDY #5
	LDA (DATA_POINTER), Y
    LSR
    STA TEMP1
    
    ; Update VMEM_POINTER
    PLA
    STA VMEM_POINTER+1
    PLA
    CLC
    ADC TEMP1
    STA VMEM_POINTER
    
            
    ; Store height in X
	LDY #6
	LDA (DATA_POINTER), Y
    TAX
    
    ; Load background color in y
    LDY $7fff
    
    ; Draw right column
    JSR _drawColumn
    
    ; Update X coord
    LDA (DATA_POINTER)
    DEA
    DEA
    STA (DATA_POINTER)  
    
    RTS
.endproc




