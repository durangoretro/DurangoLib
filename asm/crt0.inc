; ---------------------------------------------------------------------------
; DURANGO SDK. CC65 SUPPORT
; CRT0 CONSTANTS
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------

; ZERO PAGE VARS ($00-$2F)
;--------------------------
VMEM_POINTER = $00; $01
COLOUR = $20
WIDTH = $21
HEIGHT = $22
X_COORD = $23
Y_COORD = $24
TEMP1 = $25
TEMP2 = $26

; RAM VARS ($0200 - $02FF)
;--------------------------
IRQ_ADDR   = $0200 ; - $0201
NMI_ADDR   = $0202 ; - $0203
BRK_ADDR   = $0204 ; - $0205
TICKS = $0206 ; - $0209
KEY_PRESSED = $020A
KEYBOARD_TYPE = $020F
GAMEPAD_MASK = $020F ; - $0210
GAMEPAD = $0211 ; - $0212

