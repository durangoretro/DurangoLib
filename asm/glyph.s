.include "durango_constants.inc"
.PC02

.importzp sp
.import incsp8
.import incsp2
.import coords2mem

.export _printBCD
.export _printStr

; unsigned char x, unsigned char y, void* font, unsigned char color, unsigned char paper, long (4 bytes) value
; Font 5x8
.proc _printBCD: near
	; Load X coord
    LDY #9
    LDA (sp), Y
    STA X_COORD    
    
    ; Load Y coord
    DEY
    LDA (sp), Y
    STA Y_COORD
    
    ; Load font
    DEY
    LDA (sp), Y
    STA RESOURCE_POINTER+1    
    DEY
    LDA (sp), Y
    STA RESOURCE_POINTER
    
    ; Load color
    DEY
    LDA (sp), Y
    STA COLOUR
    
    ; Load paper
    DEY
    LDA (sp), Y
    STA PAPER        

    ; Calculate coords
    JSR coords2mem
	STZ TEMP1
	
	LDY #3
	LDA (sp), Y
	jsr draw_byte
	
    LDY #2
    LDA (sp), Y
	jsr draw_byte
    
    LDY #1
    LDA (sp), Y
	jsr draw_byte
    
    LDY #0
    LDA (sp), Y
	jsr draw_byte
	
	;LDA #$11
	;jsr draw_byte
	
    JSR incsp8
    JMP incsp2
.endproc

.proc  _printStr: near
    ; Load X coord
    LDY #7
    LDA (sp), Y
    STA X_COORD    
    
    ; Load Y coord
    DEY
    LDA (sp), Y
    STA Y_COORD
    
    ; Load font
    DEY
    LDA (sp), Y
    STA RESOURCE_POINTER+1    
    DEY
    LDA (sp), Y
    STA RESOURCE_POINTER
    
    ; Load color
    DEY
    LDA (sp), Y
    STA COLOUR
    
    ; Load paper
    DEY
    LDA (sp), Y
    STA PAPER        

    ; Calculate coords
    JSR coords2mem
	STZ TEMP1
    
    ; String pointer
    LDY #1
    LDA (sp), Y
    STA DATA_POINTER+1
    LDY #0
    LDA (sp), Y
    STA DATA_POINTER
	
    JSR draw_str
    JMP incsp8
	
	
.endproc

.proc draw_byte: near
	PHA
	LDX RESOURCE_POINTER
	STX TEMP3
	LDX RESOURCE_POINTER+1
	STX TEMP4
	; Left digit
	AND #$F0
	LSR
	LSR
	LSR
	LSR
	JSR find_letter
	JSR type_letter
	; Right digit
	LDX TEMP3
	STX RESOURCE_POINTER
	LDX TEMP4
	STX RESOURCE_POINTER+1
	PLA
	AND #$0F
	JSR find_letter
	JSR type_letter
	; Restore resource pointer
	LDX TEMP3
	STX RESOURCE_POINTER
	LDX TEMP4
	STX RESOURCE_POINTER+1
	RTS
.endproc

.proc draw_str: near
	; Backup resource pointer
    LDX RESOURCE_POINTER
	STX TEMP3
	LDX RESOURCE_POINTER+1
	STX TEMP4
    
    ; Iterate string
    LDY #$00
    loop:
    LDA (DATA_POINTER),Y
    BEQ end
    PHY
    JSR find_letter
	JSR type_letter
	; Restore resource pointer
	LDX TEMP3
	STX RESOURCE_POINTER
	LDX TEMP4
	STX RESOURCE_POINTER+1
    PLY
    INY
    BNE loop
    end:
    RTS
.endproc

.proc find_letter: near
	TAX
	BEQ end
	LDA RESOURCE_POINTER
	loop:
	CLC
	ADC #5
	STA RESOURCE_POINTER
	BCC skip
	INC RESOURCE_POINTER+1
	skip:
	DEX
	BNE loop
	end:
	RTS
.endproc

.proc type_letter: near
	; Save vmem pointer
	LDA VMEM_POINTER
	PHA
	LDA VMEM_POINTER+1
	PHA
	
	; Load First byte
	LDY #$00
	LDA (RESOURCE_POINTER),Y
	; Type row 1
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry

	; Type row 2
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	LDY #$01
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 3
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 4
	JSR next_row
	ASL
	JSR type_carry
	LDY #$02
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 5
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	LDY #$03
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	
	; Type row 6
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 7
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	LDY #$04
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 8
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Restore VMEM POINTER
	PLA
	STA VMEM_POINTER+1
	PLA
	STA VMEM_POINTER
	
	JMP next_letter
.endproc

.proc next_row: near
	PHA
	STZ TEMP1
	LDA VMEM_POINTER
	CLC
	ADC #62
	STA VMEM_POINTER
	BCC skip
	INC VMEM_POINTER+1	
	skip:
	PLA
	RTS
.endproc

.proc next_letter: near
	STZ TEMP1
	LDA VMEM_POINTER
	CLC
	ADC #3
	STA VMEM_POINTER
	BCC skip
	INC VMEM_POINTER+1	
	skip:
	RTS
.endproc


.proc type_carry: near
	; Keep A
	PHA
	; If carry set
	BCC carry_set
		; Load ink color
		LDA COLOUR
	; else
	BRA end
	carry_set:
		; Load paper color
		LDA PAPER
	;end if
	end:
	JSR type
	; Restore A
	PLA
	RTS
.endproc

.proc type: near
	; If left pixel
	BIT TEMP1
	BMI right_pixel
	; then
		; Keep left pixel from color
		AND #$F0
		; Store single color in temp2
		STA TEMP2
		; Load original pixel pair
		LDA (VMEM_POINTER)
		; Clear left pixel
		AND #$0F
		; Paint left pixel
		ORA TEMP2
		; Save pixel pair
		STA (VMEM_POINTER)
		; Increment position
		CLC
		LDA #%10000000
		ADC TEMP1
		STA TEMP1
	; else
	BRA end
	right_pixel:
	; then
		; Keep right pixel from color
		AND #$0F
		; Store single color in temp2
		STA TEMP2
		; Load original pixel pair
		LDA (VMEM_POINTER)
		; Clear right pixel
		AND #$F0
		; Paint left pixel
		ORA TEMP2
		; Save pixel pair
		STA (VMEM_POINTER)
		; Increment position
		CLC
		LDA #%10000000
		ADC TEMP1
		STA TEMP1
		INC VMEM_POINTER
		BNE end
		INC VMEM_POINTER+1
	; end if
	end:
	RTS
.endproc
