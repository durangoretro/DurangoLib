; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (Single Board Computer version)

.export   _init, _exit
.import   _main, _disableDoubleBuffer, _conio, _conio_ccol, _conio_cbin

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import __STACKSTART__, __STACKSIZE__

.import    copydata, zerobss, initlib, donelib

.include  "zeropage.inc"

; ---------------------------------------------------------------------------
; Place the startup code in a special segment

.segment  "STARTUP"

; ---------------------------------------------------------------------------
; A little light 6502 housekeeping

_init:
; ---------------------------------------------------------------------------  
; Enable the 65C02 instructions set
          .PSC02
; ---------------------------------------------------------------------------  
; Disable hardware periodic interrupt
          SEI                          ; Disable interrupts
; ---------------------------------------------------------------------------    
; Initialize 6502 stack
          LDX     #$FF                 ; Initialize stack pointer to $01FF
          TXS
          CLD                          ; Clear decimal mode
; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer

          LDA     #<(__STACKSTART__ + __STACKSIZE__)
          STA     sp
          LDA     #>(__STACKSTART__ + __STACKSIZE__)
          STA     sp+1

; ---------------------------------------------------------------------------
; Initialize memory storage

          JSR     zerobss              ; Clear BSS segment
          JSR     copydata             ; Initialize DATA segment
          JSR     initlib              ; Run constructors

; ---------------------------------------------------------------------------    
; Initialize Durango Video
          LDA #$3c
          STA $df80
          JSR _disableDoubleBuffer
          LDA #$0F						; standard colours, white ink on black background
          STA _conio_ccol+1				; array will be restored by FF
          STZ _conio_cbin				; IMPORTANT
          LDA #$0C						; FORM FEED will clear the screen and intialise CONIO
          JSR _conio
; ---------------------------------------------------------------------------
; Call main()

          JSR     _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:    JSR     donelib              ; Run destructors
          BRK
