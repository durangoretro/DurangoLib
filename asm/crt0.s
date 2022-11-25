; ---------------------------------------------------------------------------
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
    
    ; Clean video mode
    ; [HiRes Invert S1 S0    RGB LED NC NC]
    LDA #%00111000
    STA VIDEO_MODE

    ; Initialize stack pointer to $01FF
    LDX #$FF
    TXS

    ; Clear decimal mode
    CLD
   
    ; Initialize cc65 stack pointer
    LDA #<(__STACKSTART__ + __STACKSIZE__)
    STA sp
    LDA #>(__STACKSTART__ + __STACKSIZE__)
    STA sp+1

    ; Initialize memory storage
    JSR zerobss
    JSR copydata
    JSR initlib
    
    ; Set up IRQ subroutine
    LDA #<_irq_int
    STA IRQ_ADDR
    LDA #>_irq_int
    STA IRQ_ADDR+1
    
    ; Set up NMI subroutine
    LDA #<_nmi_int
    STA NMI_ADDR
    LDA #>_nmi_int
    STA NMI_ADDR+1
    
    ; Initialize interrupts counter
    STZ TICKS
    STZ TICKS+1
    STZ TICKS+2
    STZ TICKS+3

    ; Init gamepads
    STA GAMEPAD1
    LDX #8
    loop:
    STA GAMEPAD2
    DEX
    BNE loop
    LDA GAMEPAD1
    LDX GAMEPAD2
    STA GAMEPAD_MODE
    STX GAMEPAD_MODE+1
    
    ; Enable Durango interrupts
    LDA #$01
    STA INT_ENABLE
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
    BRA _stop


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
    INC $0206
    BNE next
    INC $0207
    BNE next
    INC $0208
    BNE next
    INC $0209
    next:
    ; Read controllers
    STA GAMEPAD1
    LDX #8
    loop2:
    STA GAMEPAD2
    DEX
    BNE loop2
    LDA GAMEPAD1
    EOR GAMEPAD_MODE
    STA GAMEPAD
    LDA GAMEPAD+1
    EOR GAMEPAD_MODE+1
    STA GAMEPAD+1
    ; Restore registers and return
    PLX
    PLA
    RTI 

; Non-maskable interrupt (NMI) service routine
_nmi_int:
    RTI

hw_irq_int:
    JMP (IRQ_ADDR)
    
hw_nmi_int:
    JMP (NMI_ADDR)

; ---------------------------------------------------------------------------
; SEGMENT VECTTORS
; ---------------------------------------------------------------------------

.segment  "VECTORS"

.addr      hw_nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      hw_irq_int    ; IRQ/BRK vector

; ---------------------------------------------------------------------------
; SEGMENT METADATA
; ---------------------------------------------------------------------------
.segment "METADATA"
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
