/*
 * Hello Durango
 * To manually build:
 * cc65 -I ../inc --cpu 6502 fill_screen.c -o fill_screen.s
 * ca65 -t none fill_screen.s -o fill_screen.o
 * ld65 -C ../cfg/durango16k.cfg fill_screen.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o fill_screen.bin
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
