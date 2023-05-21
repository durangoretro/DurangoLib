; ---------------------------------------------------------------------------
; DURANGO HARDWARE CONSTANTS
; ---------------------------------------------------------------------------
; [HiRes Invert S1 S0    RGB LED NC NC]
VIDEO_MODE = $DF80
INT_ENABLE = $DFA0
KEYBOARD = $DF9B
GAMEPAD1 = $DF9C
GAMEPAD2 = $DF9D
VSP = $DF93
VSP_CONFIG = $DF94
SYNC = $DF88
SCREEN_0 = $0000
SCREEN_1 = $2000
SCREEN_2 = $4000
SCREEN_3 = $6000

; ---------------------------------------------------------------------------
; DURANGO CRT0 CONSTANTS
; ---------------------------------------------------------------------------
GAMEPAD_MODE1 = $00
GAMEPAD_MODE2 = $01
GAMEPAD_VALUE1 = $02
GAMEPAD_VALUE2 = $03
KEYBOARD_CACHE = $04; $05; $06; $07; $08
IRQ_ADDR = $0200
NMI_ADDR = $0202
KEY_PRESSED = $020A
SIGNATURE = $FFAB
BUILD_HASH = $C0E6

; ---------------------------------------------------------------------------
; DURANGO LIB PAGE ZERO CONSTANTS ($00-$2F)
; ---------------------------------------------------------------------------
VMEM_POINTER = $10 ; $11
DATA_POINTER = $12 ; $13
X_COORD = $14
Y_COORD = $15
HEIGHT = $16
WIDTH = $17
RESOURCE_POINTER = $18 ; $19
X2_COORD = $1A
Y2_COORD = $1B
X3_COORD = $1C
Y3_COORD = $1D
X4_COORD = $1E
Y4_COORD = $1F
COLOUR = $20
PAPER = $21
BACKGROUND_POINTER = $22; $23
TEMP1 = $24
TEMP2 = $25
TEMP3 = $26
TEMP4 = $27
RANDOM_SEED = $28; 29
TEMP5 = $2A
TEMP6 = $2B
TEMP7 = $2C
TEMP8 = $2D
HEIGHT2 = $2E
WIDTH2 = $2F

; ---------------------------------------------------------------------------
; DURANGO LIB MEMORY CONSTANTS ($0200-$02FF)
; ---------------------------------------------------------------------------
TEMP11 = $020A

; ---------------------------------------------------------------------------
; VIRTUAL SERIAL PORT CONSTANTS
; ---------------------------------------------------------------------------
VSP_FOPEN = $11
VSP_FREAD = $12
VSP_FWRITE = $13
VSP_FCLOSE = $1F
VSP_HEX = $F0
VSP_ASCII = $F1
VSP_BINARY = $F2
VSP_DECIMAL = $F3
VSP_INT16 = $F4
VSP_HEX16 = $F5
VSP_INT8  = $F6
VSP_STOPWATCH_START = $FB
VSP_STOPWATCH_STOP = $FC
VSP_DUMP = $FD
VSP_STACK = $FE
VSP_STAT = $FF
