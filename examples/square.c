/*
 * Draw a square
 * To manually build:
 * cc65 -I ../inc --cpu 6502 square.c -o square.s && ca65 -t none square.s -o square.o && ld65 -C ../cfg/durango16k.cfg square.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o square.bin
 */

#include <durango.h>

int main(){
	// Draw background color
	fillScreen(YELLOW);
	// Draw rect
	drawRect(10, 20, 50, 70, GREEN);    
	return 0;
}
