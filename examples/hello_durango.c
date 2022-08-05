/*
 * Hello Durango
 * To manually build:
 * cc65 -I ../inc --cpu 6502 hello_durango.c -o hello_durango.s
 * ca65 -t none hello_durango.s -o hello_durango.o
 * ld65 -C ../cfg/durango16k.cfg hello_durango.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o hello_durango.bin
 */

#include <durango.h>

int main(){

    // Set Video Mode to RGB and use SCREEN 3 space.
    setVideoMode(RGB | SCREEN_3);
    
	//Draw Pixel pair
    drawPixelPair(10, 2, ROJO);
    
	return 0;
}
