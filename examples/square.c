/*
 * Draw a square
 * To manually build:
 * cc65 -I ../inc --cpu 6502 square.c -o square.s && ca65 -t none square.s -o square.o && ld65 -C ../cfg/durango16k.cfg square.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o square.bin
 */

#include <durango.h>

unsigned char x, y, gamepad;

int main(){
	// Initialize coords
	x = 2;
	y = 2;	

	// Draw background color
	fillScreen(YELLOW);


	while(1) {
		// Wait for VSYNC
		waitVsync();
		// Delete previously square
		drawRect(x, y, 10, 10, YELLOW);
		// Read gamepad
		gamepad=readGamepad1();
		consoleLogHex(gamepad);
		// Update square coords
		// Draw square
		drawRect(x, y, 10, 10, GREEN);
	}
	
	return 0;
}
