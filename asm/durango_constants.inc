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
IOBEEP=$DFB0
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
INT_COUNTER = $0206
KEY_PRESSED = $020A
SIGNATURE = $FFAB
BUILD_HASH = $C0E6

; ---------------------------------------------------------------------------
; DURANGO LIB PAGE ZERO CONSTANTS ($00-$2F)
; ---------------------------------------------------------------------------
VMEM_POINTER = $10 ; $11
DATA_POINTER = $12 ; $13
RESOURCE_POINTER = $14 ; $15
BACKGROUND_POINTER = $16; $17
RANDOM_SEED = $18; $19
COLOUR = $1A
PAPER = $1B
X_COORD = $1C
Y_COORD = $1D
X2_COORD = $1E
Y2_COORD = $1F
X3_COORD = $20
Y3_COORD = $21
X4_COORD = $22
Y4_COORD = $23
HEIGHT = $24
WIDTH = $25
HEIGHT2 = $26
WIDTH2 = $27
TEMP1 = $28
TEMP2 = $29
TEMP3 = $2A
TEMP4 = $2B
TEMP5 = $2C
TEMP6 = $2D
TEMP7 = $2E
TEMP8 = $2F


; ---------------------------------------------------------------------------
; DURANGO LIB MEMORY CONSTANTS ($0200-$02FF)
; ---------------------------------------------------------------------------
TEMP11 = $020A
TEMP12 = $020B
TEMP13 = $020C
TEMP14 = $020D
TEMP15 = $020E
TEMP16 = $020F
TEMP17 = $0210
TEMP18 = $0211
TEMP19 = $0212
TEMP20 = $0213

; ---------------------------------------------------------------------------
; VIRTUAL SERIAL PORT CONSTANTS
; ---------------------------------------------------------------------------
VSP_FOPEN = $11
VSP_FREAD = $12
VSP_FWRITE = $13
VSP_FCLOSE = $1F
PSV_RAW_INIT  = $20
PSV_RAW_SEEK  = $21
PSV_RAW_READ  = $22
PSV_RAW_WRITE = $23
PSV_RAW_CLOSE = $24
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
