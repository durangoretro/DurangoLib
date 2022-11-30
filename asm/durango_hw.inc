; ---------------------------------------------------------------------------
; DURANGO HARDWARE CONSTANTS
; @author: Emilio Lopez Berenguer emilio@emiliollbb.net
; @author: Carlos Santisteban Salinas zuiko21@gmail.com
; @author: Victor Suárez García zerasul@gmail.com
; ---------------------------------------------------------------------------

SCREEN_0 = $0000
SCREEN_1 = $2000
SCREEN_2 = $4000
SCREEN_3 = $6000

; built-in devices
VIDEO_MODE = $DF80    ; [HiRes Invert S1 S0    RGB LED NC NC]
SYNC       = $DF88    ; [H V · ·  · · · ·]
INT_ENABLE = $DFA0
AUDIO_OUT  = $DFB0

; peripheral bus
VSP        = $DF93
VSP_CONFIG = $DF94
PASK_PORT  = $DF9A
MATRIX_KEYBOARD = $DF9B
GAMEPAD1   = $DF9C
GAMEPAD2   = $DF9D
