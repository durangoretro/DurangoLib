; ---------------------------------------------------------------------------
; DURANGO SDK. CC65 SUPPORT
; Durango Initialization
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (Single Board Computer version)

.import   _main

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import __STACKSTART__, __STACKSIZE__
.import    copydata, zerobss, initlib, donelib

.include  "zeropage.inc"
.include "durango_hw.inc"
.include "crt0.inc"

; Enable 65C02 instruction set
.PC02

; ---------------------------------------------------------------------------
; SEGMENT STARTUP
; ---------------------------------------------------------------------------
.segment  "STARTUP"


; Initialize Durango X
_init:
    ; Disable interrupts
    SEI
    ; Clear decimal mode
    CLD
    ; Initialize stack pointer to $01FF
    LDX #$FF
    TXS
    
    ; Durango-X specific stuff
    ; Enable Durango interrupt hardware (turn off Error LED)
    STX INT_ENABLE          ; any odd value, like $FF, will do
    
    ; Clean video mode
    ; [HiRes Invert S1 S0    RGB LED NC NC]
    LDA #%00111000
    STA VIDEO_MODE


   
    ; Initialize cc65 stack pointer
    LDY #<(__STACKSTART__ + __STACKSIZE__)
    LDA #>(__STACKSTART__ + __STACKSIZE__)
    STY sp
    STA sp+1

    ; Initialize memory storage
    JSR zerobss
    JSR copydata
    JSR initlib
    
    ; Interrupt setup
    ; Set up IRQ subroutine
    LDY #<_irq_int
    LDA #>_irq_int
    STY IRQ_ADDR
    STA IRQ_ADDR+1
    
    ; Set up NMI subroutine
    LDY #<_nmi_int
    LDA #>_nmi_int
    STY NMI_ADDR
    STA NMI_ADDR+1
    
    ; Initialize interrupts counter and other stuff
    LDX #3                  ; byte offset = 0...3
    cl_loop:
    STZ TICKS, X            ; interrupts counter
    DEX
    BPL cl_loop
    
    ; Init gamepads
    STA GAMEPAD1            ; latch pad values
    LDX #7
    loop:
    STA GAMEPAD2                ; send clock pulses
    STZ KEYBOARD_MODIFIERS, X   ; this will init some matrix keyboard and CONIO stuff
    DEX
    BPL loop
    LDA GAMEPAD1            ; check base values
    LDX GAMEPAD2
    STA GAMEPAD_MASK1
    STX GAMEPAD_MASK2
    
    ; Select keyboard driver EEEEEEEK
	LDX #0					; default is PASK
	LDA #32					; column 6
	STA MATRIX_KEYBOARD		; select it
	LDA MATRIX_KEYBOARD		; and read rows
	CMP #$58				; is it a 5x8 matrix?
	BNE not_5x8
		LDX #2				; set as default keyboard
not_5x8:
	STX KEYBOARD_TYPE		; set selected type
    
    ; Enable Durango interrupts
    CLI
    
    ; Call main()
    JSR _main

; Back from main (also the _exit entry):
_exit:
    ; Run destructors
    JSR donelib

; Stop
_stop:
    STP
    NOP
    NOP
    JMP _stop       ; universal code

; ***************** ISR *****************
; Maskable interrupt (IRQ) service routine
_irq_int:  
    ; Save registres and filter BRK
    PHA
    PHX
    TSX
    LDA $103,X
    AND #$10
    BNE _stop
    ; Increment interrupt counter
    INC TICKS
    BNE next
    INC TICKS+1
    BNE next
    INC TICKS+2
    BNE next
    INC TICKS+3
    next:
    ; Read controllers
    STA GAMEPAD1        ; latch values
    LDX #8
    loop2:
    STA GAMEPAD2        ; send clock pulses
    DEX
    BNE loop2
    LDA GAMEPAD1
    EOR GAMEPAD_MASK1
    STA GAMEPAD_VALUE1
    LDA GAMEPAD2
    EOR GAMEPAD_MASK2
    STA GAMEPAD_VALUE2
    ; Read keyboard thru selected driver
    JSR kbd_isr
    ; Restore registers and return
    PLX
    PLA
; Non-maskable interrupt (NMI) service routine, does nothing by default
_nmi_int:
    RTI 

; *** keyboard drivers ***
    kbd_isr:
	LDX KEYBOARD_TYPE
    .byte $cb               ; WAI, check X value, must be either 0 or 2!
	JMP (kbd_drv, X)		; CMOS only

; *** drivers pointer list ***
kbd_drv:
	.word	drv_pask
	.word	drv_5x8         ; must save Y

; *** generic PASK driver ***
drv_pask:
	LDA PASK_PORT   		; PASK peripheral address
	STA KEY_PRESSED			; store for software
	RTS

; *** 5x8 integrated matrix keyboard ***
drv_5x8:
    PHY                     ; * needed for DurangoLib ISR *
	LDY #0
	STY KEYBOARD_MODIFIERS	; reset modifiers (no need for STZ)
	INY						; column 1 has CAPS SHIFT
	STY MATRIX_KEYBOARD		; select column
	LDA MATRIX_KEYBOARD		; get rows
	ASL						; extract ROW8 (SPACE)...
	ASL						; ...then ROW7 (ENTER)...
	ASL						; ...and finally ROW6 (SHIFT) into C (3b, 6t; was 6b, 7/8t)
	ROR KEYBOARD_MODIFIERS	; insert CAPS bit at left (will end at d6)
	INY						; second column
	STY MATRIX_KEYBOARD		; select it
	LDA MATRIX_KEYBOARD		; and read its rows
	ASL						; only d7 is interesting (ALT, aka SYMBOL SHIFT)
	ROR KEYBOARD_MODIFIERS	; insert ALT bit at d7
	LDY #5					; prepare to scan backwards (note indices are 1...5)
col_loop:
		LDA col_bit-1, Y	; get bit position for column, note offset
		STA MATRIX_KEYBOARD	; select column
		LDA MATRIX_KEYBOARD	; and read it
;		STZ MATRIX_KEYBOARD	; deselect all, not necessary but lower power (CMOS only)
		AND k_mask-1, Y		; discard modifier bits, note offset
		BEQ kb_skip			; no keys from this column
			LDX #7			; row loop (row indices are 0...7)
row_loop:
			ASL				; d7 goes first
			BCS key_pr		; detected keypress!
			DEX
			BPL row_loop	; all 8 rows
kb_skip:
		DEY					; next column
		BNE col_loop
; if arrived here, no keys (beside modifiers) were pressed
	STY KEYBOARD_SCAN		; Y is zero, which is now an invalid scancode
	LDA #DELAY				; reset key repeat
	STA KEYBOARD_REPEAT
no_key:
	LDA #0					; 0 means no (new) key was pressed
set_key:					; common ASCII code output, with or without actual key
	STA KEY_PRESSED			; return ASCII code (0 = no key)
    PLY                     ; * OK for DurangoLib *
	RTS
; otherwise, a key was detected
key_pr:
	TYA						; get column index (1...5)
	ASL
	ASL
	ASL						; times 8 (8...40)
	STX KEY_PRESSED			; TEMPORARY STORAGE of ·····XXX
	ORA KEY_PRESSED			; A = ··YYYXXX
	BIT KEYBOARD_CONTROL	; is control-mode enabled?
	BMI ctl_key				; check different table (without checking any modifiers nor repeat)
		ORA KEYBOARD_MODIFIERS		; scancode is complete in A
; look for new or repeated key
		CMP KEYBOARD_SCAN	; same as before?
		BNE diff_k			; nope, just generate new keystroke
			DEC KEYBOARD_REPEAT		; otherwise update repeat counter
				BNE no_key	        ; if not expired, just simulate released key for a while
			LDX #RATE		        ; I believe this goes here...
			STX KEYBOARD_REPEAT		; the counter is reset, repeat current keystroke
diff_k:
		STA KEYBOARD_SCAN	; in any case, update last scancode as new keystroke
		TAX					; use scancode as index
		LDA kb_map-8, X		; get ASCII from layout, note offset
		CMP #$FF			; invalid ASCII, this will change into CTRL mode
		BNE set_key			; not the CONTROL combo, all done
			STA KEYBOARD_CONTROL	; otherwise, $FF sets d7 for CTRL mode
			JMP no_key		        ; no ASCII for now
; if arrived here, a key was pressed while in CONTROL mode (will not repeat)
ctl_key:
	TAX						; use scancode (without modifiers) as index
	LDA ctl_map-8, X		; get ASCII from CONTROL-mode layout, note offset
		BEQ no_key			; invalid ASCII, this will stay into CTRL mode
	STA KEYBOARD_CONTROL	; otherwise clear d7, no longer in CTRL mode (works as none of control codes is over 127)
	BNE set_key				; and send that control code (hopefully no need for BRA)

; *******************
; *** data tables ***
; *******************

; *** standard keymap, first 8 bytes removed ***
kb_map:
; unshifted keys (d7d6=00)
	.byte	"1qa0p", 0, $D, ' '		; column 1, note SHIFT disabled (scan = 8...$F)
	.byte	"2ws9ozl", 0			; column 2, note ALT disabled (scan = $10...$17)
	.byte	"3ed8ixkm"				; column 3 (scan = $18...$1F)
	.byte	"4rf7ucjn"				; column 4 (scan = $20...$27)
	.byte	"5tg6yvhb"				; column 5 (scan = $28...$2F)
; * note 24-byte gap *
; bit positions for every column (may place in gaps)
col_bit:
	.byte	1, 2, 4, 8, 16
; valid row bits minus shift keys
k_mask:
	.byte	%11011111, %01111111, %11111111, %11111111, %11111111
; * filling after tables inside gap *
	.res	14, 0
kb_s_map:
; SHIFTed keys (d6=1)
	.byte	$1B, "QA", 8, 'P', 0, $D, 3		; column 1, note SHIFT disabled (scan = $48...$4F)
	.byte	9, "WS", $FF, "OZL", 0			; column 2, note ALT disabled and CTRL code switch (scan = $50...$57)
	.byte	$F, "ED", 6, "IXKM"				; column 3 (scan = $58...$5F)
	.byte	$E, "RF", $B, "UCJN"			; column 4 (scan = $60...$67)
	.byte	2, "TG", $A, "YVHB"				; column 5 (scan = $68...$6F)
; note 24-byte gap
	.res	24, 0
kb_a_map:
; ALTed keys (d7=1)
	.byte	'!', $A1,$E1, '_', $22,0,$F1, 0	; column 1, note SHIFT disabled (scan = $88...$8F)
	.byte	"@~;)", $F3, ":=", 0			; column 2, note ALT disabled (scan = $90...$97)
	.byte	'#', $E9, "|(", $ED, $BF, "+."	; column 3 (scan = $98...$9F)
	.byte	"$<['", $FA, "?-,"				; column 4 (scan = $A0...$A7)
	.byte	"%>]&", $FC, '/', $5E, '*'		; column 5 (scan = $A8...$AF)
; note 24-byte gap
	.res	24, 0
kb_as_map:
; SHIFT+ALT (d7d6=11)
	.byte	0, $B0, $C1, 0, 0, 0, $D1, 0	; column 1, note SHIFT disabled (scan = $C8...$CF)
	.byte	$18, 0, 0, 0, $D3, 0, 0, 0		; column 2, note ALT disabled (scan = $D0...$D7)
	.byte	0, $C9, $5C, 5, $CD, $A4, 0, 0	; column 3 (scan = $D8...$DF)
	.byte	0, $96, '{', $19, $DA, 0, 0, 0	; column 4 (scan = $E0...$E7)
	.byte	1, $98, '}', $16, $DC, 0, 0, 0	; column 5 (scan = $E8...$EF)

; *** control mode keymap, first 8 bytes removed *** may split in 16-byte chunks between gaps
ctl_map:
	.byte	$1B, $11, 1, 0, $10, 0, 0, 0		; column 1, note SHIFT disabled (scan = 8...$F)
	.byte	$1C, $17, $13, 0, $F, $1A, $C, 0	; column 2, note ALT disabled (scan = $10...$17)
	.byte	$1D, 5, 4, 0, 9, $18, $B, $D		; column 3 (scan = $18...$1F)
	.byte	$1E, $12, 6, 0, $15, 3, $A, $E		; column 4 (scan = $20...$27)
	.byte	$1F, $14, 7, 0, $19, $16, 8, 2		; column 5 (scan = $28...$2F)

; ***************************
; Vectored Interrupt handlers
hw_irq_int:
    JMP (IRQ_ADDR)
    
hw_nmi_int:
    JMP (NMI_ADDR)

; ---------------------------------------------------------------------------
; SEGMENT VECTTORS
; ---------------------------------------------------------------------------

.segment  "VECTORS"

.addr      hw_nmi_int    ; NMI vector
.addr      _init         ; Reset vector
.addr      hw_irq_int    ; IRQ/BRK vector

; ---------------------------------------------------------------------------
; SEGMENT METADATA
; ---------------------------------------------------------------------------
.segment "METADATA"
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byt "SIGNATURE:["
.byt $00,$00
.byt "]$$"

; ---------------------------------------------------------------------------
; SEGMENT HEADER
; ---------------------------------------------------------------------------
.segment "HEADER"
.byt "DURANGO CC65v1.0"
.byt "##DURANGO LIB###"
.byt "################"
