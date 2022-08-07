/*
 * Hello Durango
 * To manually build:
 * cc65 -I ../inc --cpu 6502 hello_durango.c -o hello_durango.s
 * ca65 -t none hello_durango.s -o hello_durango.o
 * ld65 -C ../cfg/durango16k.cfg hello_durango.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o hello_durango.bin
 */

#include <durango.h>

int main(){
	// Draw some pixels
	drawPixel(0, 0, ORANGE);
	drawPixel(0, 0, YELLOW);
	drawPixel(0, 0, LAVENDER_ROSE);
	drawPixel(0, 0, CIAN);
	drawPixel(0, 0, PINK_FLAMINGO);
	drawPixel(0, 0, WHITE);


	// You can also draw Pixels in paris, which is faster
    drawPixelPair(0, 2, RED);
	drawPixelPair(2, 2, GREEN);
	drawPixelPair(4, 2, BLUE);
    
	return 0;
}
