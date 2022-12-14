; ---------------------------------------------------------------------------
; DURANGO SDK. CC65 SUPPORT
; CRT0 CONSTANTS
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------

; CONSTANTS
;-------------------------
RATE = 25
DELAY = 175

; ZERO PAGE VARS ($00-$2F)
;--------------------------
VMEM_POINTER = $00                          ; $00
DATA_POINTER = VMEM_POINTER + 2             ; $02
BACKGROUND_POINTER = DATA_POINTER + 2       ; $04
RESOURCE_POINTER = BACKGROUND_POINTER + 2   ; $06
WIDTH   = RESOURCE_POINTER + 2              ; $08
HEIGHT  = WIDTH + 1                         ; $09
X_COORD = HEIGHT + 1                        ; $0A
Y_COORD = X_COORD + 1                       ; $0B
COLOUR  = Y_COORD + 1                       ; $0C
TEMP1 = COLOUR + 1                          ; $0D
TEMP2 = TEMP1 + 1                           ; $0E
TEMP3 = TEMP2 + 1                           ; $0F
GAMEPAD_MASK1  = TEMP3 + 1                  ; $10
GAMEPAD_MASK2  = GAMEPAD_MASK1 + 1          ; $11
GAMEPAD_VALUE1 = GAMEPAD_MASK2 + 1          ; $12
GAMEPAD_VALUE2 = GAMEPAD_VALUE1 + 1         ; $13
; CONIO data structures
CONIO_TCOL = GAMEPAD_VALUE2 + 1             ; $14 (aka _ccol)
CONIO_POSI = CONIO_TCOL + 4                 ; $18 (aka _ciop)
CONIO_TEMP = CONIO_POSI + 2                 ; $1A (temp, aka _cbyt, _chalf)
CONIO_SCUR = CONIO_TEMP + 1                 ; $1B
ZP_SPACE = CONIO_SCUR + 1                   ; $1C...$2B, unused
; reserved space for interrupts only
INTERRUPT_POINTER = $2C                     ; $2C
INTERRUPT_SPARE   = INTERRUPT_POINTER + 2   ; $2E, may be used as pointer
INTERRUPT_DATA    = INTERRUPT_SPARE + 1     ; $2F

; RAM VARS ($0200 - $02FF)
;--------------------------
IRQ_ADDR = $0200
NMI_ADDR = IRQ_ADDR + 2                     ; $0202
BRK_ADDR = NMI_ADDR + 2                     ; $0204
TICKS    = BRK_ADDR + 2                     ; $0206
KEY_PRESSED = TICKS + 4                     ; $020A
; matrix keyboard driver
KEYBOARD_MODIFIERS = KEY_PRESSED + 1        ; $020B (temp?)
KEYBOARD_CONTROL = KEYBOARD_MODIFIERS + 1   ; $020C
KEYBOARD_SCAN = KEYBOARD_CONTROL + 1        ; $020D
KEYBOARD_REPEAT	= KEYBOARD_SCAN + 1         ; $020E	
KEYBOARD_TYPE = KEYBOARD_REPEAT + 1         ; $020F
; CONIO global variables
CONIO_MODE = KEYBOARD_TYPE + 1              ; $0210 (aka _cbin)
CONIO_MASK = CONIO_MODE + 1                 ; $0211
CONIO_FONT = CONIO_MASK + 1                 ; $0212
CONIO_LAST = CONIO_FONT + 2                 ; $0214 (aka _io9)
CONIO_KBDPAD = CONIO_LAST + 1               ; $0215 (1 byte, aka _knes)
; $0216 - $02FF unused
