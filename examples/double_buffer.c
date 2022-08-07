/*
 * Draw a square
 * To manually build:
 * cc65 -I ../inc --cpu 6502 double_buffer.c -o double_buffer.s && ca65 -t none double_buffer.s -o double_buffer.o && ld65 -C ../cfg/durango16k.cfg double_buffer.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o double_buffer.bin
 */

#include <durango.h>

unsigned char x, y, gamepad;

int main(){
	// Initialize coords
	x = 2;
	y = 2;	

	enableDoubleBuffer();

	// Draw background color
	fillScreen(YELLOW);


	while(1) {
		// Wait for VSYNC
//		waitVsync();
		// Draw background color
		fillScreen(YELLOW);
		// Read gamepad
		gamepad=readGamepad1();
		// Update square coords
		if(gamepad & BUTTON_DOWN) {
			y++;
			y++;
		}
		else if(gamepad & BUTTON_UP) {
			y--;
			y--;
		}
		else if(gamepad & BUTTON_LEFT) {
			x--;
			x--;
		}
		else if(gamepad & BUTTON_RIGHT) {
			x++;
			x++;
		}		
		// Draw square
		drawRect(x, y, 10, 10, GREEN);
		swapBuffers();		

		waitFrames(1);
	}
	
	return 0;
}
