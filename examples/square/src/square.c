/*
 * Control a Square using Gameplad.
 * To Run this example on Perdita use flag -g and WSAD controls
 * To manually build:
 * make && make -C examples/squares
 */

#include <durango.h>
//Global Variables
unsigned char x, y, gamepad;

int main(){
	// Initialize coords
	x = 2;
	y = 2;	

	// Draw background color
	drawFullScreen(BLACK);


	while(1) {
		// Wait for VSYNC
		waitVSync();
		// Delete previously square
		drawFillRect(x, y, 10, 10, BLACK);
		// Read gamepad
		gamepad=readGamepad(GAMEPAD_1);
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
		drawFillRect(x, y, 10, 10, BLUE);
		//Wait 1 Frame
		waitFrames(1);
	}
	
	return 0;
}
