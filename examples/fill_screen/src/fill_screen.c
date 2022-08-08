/*
 * Hello Durango
 * To manually build:
 *  Use Makefile after compile the lib:
 *  cd ../..
 *  make all
 *  cd examples/fillscreen
 *  make
 */

#include <durango.h>

int main(){
    while(1) {
		// Fill screen
    	fillScreen(GREEN);
		// Wait 10 frames
		waitFrames(50);
		// Fill screen
    	fillScreen(YELLOW);
		// Wait 10 frames
		waitFrames(30);
		// Fill screen
    	fillScreen(RED);
		// Wait 10 frames
		waitFrames(50);
	}
    
	return 0;
}
