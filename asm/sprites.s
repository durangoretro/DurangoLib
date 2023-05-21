.include "durango_constants.inc"
.PC02

.importzp sp
.import incsp4
.import coords2mem

.export _load_background
.export _clrscr
.export _draw_sprite
.export _move_sprite_right
.export _move_sprite_left
.export _move_sprite_down
.export _move_sprite_up
.export _clean_sprite
.export _stamp_sprite
.export _check_collisions

.proc _load_background: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Init video pointer
    LDA #>SCREEN_2
    STA VMEM_POINTER+1
    STZ VMEM_POINTER
    rle_loop:
	LDY #0				; always needed as part of the loop
	LDA (DATA_POINTER), Y		; get command
	INC DATA_POINTER				; advance read pointer
	BNE rle_0
	INC DATA_POINTER+1
    rle_0:
	TAX					; command is just a counter
	BMI rle_u		; negative count means uncompressed string
    ; * compressed string decoding ahead *
	BEQ rle_exit		; 0 repetitions means end of 'file'
    ; multiply next byte according to count
	LDA (DATA_POINTER), Y		; read immediate value to be repeated
    rc_loop:
	STA (VMEM_POINTER), Y	; store one copy
	INY				; next copy, will never wrap as <= 127
	DEX				; one less to go
	BNE rc_loop
    ; burst generated, must advance to next command!
	INC DATA_POINTER
	BNE rle_next		; usually will skip to common code
	INC DATA_POINTER+1
	BNE rle_next	; no need for BRA
    ; * uncompressed string decoding ahead *
    rle_u:
	LDA (DATA_POINTER), Y	; read immediate value to be sent, just once
	STA (VMEM_POINTER), Y	; store it just once
	INY				; next byte in chunk, will never wrap as <= 127
	INX				; one less to go
	BNE rle_u
	TYA					; how many were read?
    rle_adv:
	CLC
	ADC DATA_POINTER				; advance source pointer accordingly (will do the same with destination)
	STA DATA_POINTER
	BCC rle_next		; check possible carry
	INC DATA_POINTER+1
    ; * common code for destination advence, either from compressed or un compressed
    rle_next:
	TYA					; once again, these were the transferred/repeated bytes
	CLC
	ADC VMEM_POINTER				; advance desetination pointer accordingly
	STA VMEM_POINTER
	BCC rle_loop		; check possible carry
	INC VMEM_POINTER+1
	BNE rle_loop		; no need for BRA
    ; *** end of code ***
    rle_exit:
    RTS
.endproc

.proc _clrscr: near
    ; Init data pointer
    LDA #>SCREEN_2
    STA DATA_POINTER+1
    STZ DATA_POINTER
    
    ; Init vmem pointer
    LDA #>SCREEN_3
    STA VMEM_POINTER+1
    STZ VMEM_POINTER
    
    loop:
    LDA (DATA_POINTER),Y
    STA (VMEM_POINTER),Y
    INY
    BNE loop
	INC DATA_POINTER+1
	INC VMEM_POINTER+1
    BPL loop

	RTS
.endproc

.proc render_sprite_pixel_pair: near
    LDA X2_COORD
    BMI end_transp
    ; Column in Y
    LDA (RESOURCE_POINTER),Y
    TAX
    ; Check if transparency
    LDA trtab, X
    STA TEMP3
    BNE transp
    ; If not transparent
    TXA
    STA (VMEM_POINTER),Y
    BRA end_transp
    transp:
    ; else
    ; Load background in A
    LDA (BACKGROUND_POINTER),Y
    ; AND mask
    AND TEMP3
    ; OR sprite
    ORA (RESOURCE_POINTER),Y
    ; Draw on screen
    STA (VMEM_POINTER),Y
    ; end else
    end_transp:
    RTS
.endproc

.proc render_sprite_row: near
    loop2:
    LDY WIDTH
    DEY
    TYA
    ASL
    ADC X_COORD
    STA X2_COORD
    loop:
    JSR render_sprite_pixel_pair
    DEC X2_COORD
    DEC X2_COORD
    DEY
    BPL loop
    RTS
.endproc

.proc render_sprite: near
    loop2:
    JSR render_sprite_row
    CLC
    LDA VMEM_POINTER
    ADC #$40
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    BCC skip
    INC VMEM_POINTER+1
    INC BACKGROUND_POINTER+1
    skip:
    CLC
    LDA RESOURCE_POINTER
    ADC WIDTH
    STA RESOURCE_POINTER
    BCC skip2
    INC RESOURCE_POINTER+1
    skip2:
    DEC HEIGHT
    BNE loop2
    RTS
.endproc

.proc _draw_sprite: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    LDY #0
    LDA (DATA_POINTER),Y
    STA X_COORD
    INY
    LDA (DATA_POINTER),Y
    STA Y_COORD
    
    ; Video pointer
    JSR coords2mem
    LDY #2
    LDA VMEM_POINTER
    STA (DATA_POINTER),Y
    STA BACKGROUND_POINTER
    INY
    LDA VMEM_POINTER+1
    STA (DATA_POINTER),Y    
    AND #$df
    STA BACKGROUND_POINTER+1
    
    ; width & height
    INY
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    ; Resource pointer
    LDY #6
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER+1

    JMP render_sprite
.endproc

.proc _move_sprite_right: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Video pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    
    ; width & height
    INY
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    ; Update x,y coord
    LDY #1
    LDA (DATA_POINTER),Y
    STA Y_COORD
    LDA (DATA_POINTER)
    INA
    INA
    STA (DATA_POINTER)
    STA X_COORD
    BNE nonzero
    
    ; Recalculate vmem position on zero
    JSR coords2mem
    LDY #2
    LDA VMEM_POINTER
    STA (DATA_POINTER),Y
    INY
    LDA VMEM_POINTER+1
    STA (DATA_POINTER),Y
    BRA skip3
    nonzero:
    
    ; Update vmem position
    LDY #2
    LDA (DATA_POINTER),Y
    CLC
    ADC #1
    STA (DATA_POINTER),Y
    BCC skip3
    INY
    LDA (DATA_POINTER),Y
    INA
    STA (DATA_POINTER),Y
    skip3:
    ; Copy pixel pair from cache to screen
    LDX HEIGHT
    loop:
    LDA (BACKGROUND_POINTER)
    STA (VMEM_POINTER)
    ; Next row
    CLC
    LDA VMEM_POINTER
    ADC #$40
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    BCC skip
    INC VMEM_POINTER+1
    INC BACKGROUND_POINTER+1
    skip:
    DEX
    BPL loop

    ; Resource pointer
    LDY #6
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER+1
    ; VMEM pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    JMP render_sprite
.endproc

.proc _move_sprite_left: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; width & height
    LDY #4
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    DEA
    STA TEMP3
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    ; Set Video pointer on last column
    LDY #2
    LDA (DATA_POINTER),Y
    CLC
    ADC TEMP3
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    BCC skip4
    INA
    skip4:
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    
    ; Delete last column of sprite
    LDX HEIGHT
    loop:
    LDA (BACKGROUND_POINTER)
    STA (VMEM_POINTER)
    ; Next row
    CLC
    LDA VMEM_POINTER
    ADC #$40
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    BCC skip
    INC VMEM_POINTER+1
    INC BACKGROUND_POINTER+1
    skip:
    DEX
    BPL loop

    ; Update x,y coord
    LDY #1
    LDA (DATA_POINTER),Y
    STA Y_COORD
    LDA (DATA_POINTER)
    DEA
    DEA
    STA (DATA_POINTER)
    STA X_COORD
    BNE nonzero
    
    ; Recalculate vmem position on zero
    JSR coords2mem
    LDY #2
    LDA VMEM_POINTER
    STA (DATA_POINTER),Y
    INY
    LDA VMEM_POINTER+1
    STA (DATA_POINTER),Y
    BRA skip3
    nonzero:
    
    ; Update vmem position
    LDY #2
    LDA (DATA_POINTER),Y
    SEC
    SBC #1
    STA (DATA_POINTER),Y
    BCS skip3
    INY
    LDA (DATA_POINTER),Y
    DEA
    STA (DATA_POINTER),Y
    skip3:    
    
    ; Resource pointer
    LDY #6
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER+1
    ; VMEM pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    JMP render_sprite
.endproc

.proc _move_sprite_down: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Video pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    
    ; width & height
    INY
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    ; Update y coord
    LDY #1
    LDA (DATA_POINTER),Y
    INA
    STA (DATA_POINTER),Y
    
    ; Update vmem position
    LDY #2
    LDA (DATA_POINTER),Y
    CLC
    ADC #$40
    STA (DATA_POINTER),Y
    BCC skip
    INY
    LDA (DATA_POINTER),Y
    INA
    STA (DATA_POINTER),Y
    skip:
    
    ; Copy pixel pair from cache to screen
    LDY WIDTH
    DEY
    loop:
    LDA (BACKGROUND_POINTER),Y
    STA (VMEM_POINTER),Y
    DEY
    BPL loop
    
    ; Draw sprite
    ; Resource pointer
    LDY #6
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER+1
    ; VMEM pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    JMP render_sprite
.endproc

.proc _move_sprite_up: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Video pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    
    ; width & height
    INY
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    ; Update y coord
    LDY #1
    LDA (DATA_POINTER),Y
    DEA
    STA (DATA_POINTER),Y
    
    ; Update vmem position
    LDY #2
    LDA (DATA_POINTER),Y
    SEC
    SBC #$40
    STA (DATA_POINTER),Y
    BCS skip
    INY
    LDA (DATA_POINTER),Y
    DEA
    STA (DATA_POINTER),Y
    skip:
    
    ; Draw sprite
    ; Resource pointer
    LDY #6
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER+1
    ; VMEM pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    JSR render_sprite
    
    ; Copy pixel pair from cache to screen
    LDY WIDTH
    DEY
    loop:
    LDA (BACKGROUND_POINTER),Y
    STA (VMEM_POINTER),Y
    DEY
    BPL loop
    
    RTS
.endproc

.proc _clean_sprite: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Video pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER+1
    AND #$df
    STA BACKGROUND_POINTER+1
    
    ; width & height
    INY
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    LDX HEIGHT
    loop2:
    ; Copy pixel pair from cache to screen
    LDY WIDTH
    DEY
    loop:
    LDA (BACKGROUND_POINTER),Y
    STA (VMEM_POINTER),Y
    DEY
    BPL loop
    ; Increase data pointer one row
    CLC
    LDA VMEM_POINTER
    ADC #$40
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    BCC skip
    INC VMEM_POINTER+1
    INC BACKGROUND_POINTER+1
    skip:
    ; Next interation
    DEX
    BPL loop2

    RTS
.endproc

.proc _stamp_sprite: near
    ; Read pointer location
    STA DATA_POINTER
    STX DATA_POINTER+1
    
    ; Video pointer
    LDY #2
    LDA (DATA_POINTER),Y
    STA VMEM_POINTER
    STA BACKGROUND_POINTER
    INY
    LDA (DATA_POINTER),Y
    AND #$df
    STA VMEM_POINTER+1
    STA BACKGROUND_POINTER+1
    
    ; width & height
    INY
    LDA (DATA_POINTER),Y
    LSR
    STA WIDTH
    INY
    LDA (DATA_POINTER),Y
    STA HEIGHT
    
    ; Resource pointer
    LDY #6
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER
    INY
    LDA (DATA_POINTER),Y
    STA RESOURCE_POINTER+1

    JMP render_sprite
.endproc

.proc _check_collisions: near
    ; Load first parameter
    LDY #3
    LDA (sp), Y
    STA DATA_POINTER+1    
    DEY
    LDA (sp), Y
    STA DATA_POINTER
    
    ; Load second parameter
    DEY
    LDA (sp), Y
    STA RESOURCE_POINTER+1    
    DEY
    LDA (sp), Y
    STA RESOURCE_POINTER
    
    JSR calculate_cols_coords
    JSR check_cols_coords
    PHA
    
    JSR incsp4
    PLA
    RTS
.endproc

.proc calculate_cols_coords: near
    ; Load X1
	LDY #0
	LDA (DATA_POINTER), Y
    STA X_COORD
    ; Load Y1
    INY
    LDA (DATA_POINTER), Y
    STA Y_COORD
    ; Load width1
    LDY #4
    LDA (DATA_POINTER), Y
    STA WIDTH
    ; Load height1
    INY
    LDA (DATA_POINTER), Y
    STA HEIGHT
    ; Calculate X2
    CLC
    LDA X_COORD
    ADC WIDTH
    STA X2_COORD
    ; Calculate Y2
    CLC
    LDA Y_COORD
    ADC HEIGHT
    STA Y2_COORD
    
    ; Load X2
	LDY #0
	LDA (RESOURCE_POINTER), Y
    STA X3_COORD
    ; Load Y2
    INY
    LDA (RESOURCE_POINTER), Y
    STA Y3_COORD
    ; Load width2
    LDY #4
    LDA (RESOURCE_POINTER), Y
    STA WIDTH2
    ; Load height2
    INY
    LDA (RESOURCE_POINTER), Y
    STA HEIGHT2
    ; Calculate X4
    CLC
    LDA X3_COORD
    ADC WIDTH2
    STA X4_COORD
    ; Calculate Y4
    CLC
    LDA Y3_COORD
    ADC HEIGHT2
    STA Y4_COORD
    
    RTS
.endproc

.proc check_cols_coords: near
    ; B right to A X2<X3
    LDX X2_COORD
    CPX X3_COORD
    BCC no_coll
    
    ; A right to B X4<X1
    LDX X4_COORD
    CPX X_COORD
    BCC no_coll
    
    ; A above B Y2<Y3
    LDX Y2_COORD
    CPX Y3_COORD
    BCC no_coll
    
    ; B above A Y4<Y1
    LDX Y4_COORD
    CPX Y_COORD
    BCC no_coll
    

    LDA #1
    RTS
    no_coll:
    LDA #0
    RTS
.endproc


; *** transparency data table(s) ***
trtab:
; use $0 for opaque nibbles, $F for transparent. If ZERO is the transparency index, as recommended, make table like this
;            0     1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
    .byt	$FF, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0 ; 0
	.byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 1
	.byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 2
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 3
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 4
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 5
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 6
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 7
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 8
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 9
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; A
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; B
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; C
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; D
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; E
    .byt	$0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; F
