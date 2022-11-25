.include "durango_hw.inc"
.include "crt0.inc"
.PC02

.export _fillScreen


.proc _fillScreen: near
    LDX #>SCREEN_3
    STX VMEM_POINTER+1
    LDY #<SCREEN_3
    STY VMEM_POINTER
    loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
	INC VMEM_POINTER+1
    BPL loop
    RTS
.endproc
