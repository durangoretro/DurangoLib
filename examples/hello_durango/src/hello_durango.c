/*
 * Hello Durango
 * To manually build:
 * make && make -C examples/hello_durango
 */

#include <durango.h>

int main(){
	fillScreen(WHITE);
	
	// Draw some pixels
	drawPixel(0, 0, ORANGE);
	drawPixel(2, 0, LAVENDER_ROSE);
	drawPixel(5, 0, RED);
	
	drawPixel(1, 1, ORANGE);
	drawPixel(3, 1, LAVENDER_ROSE);
	drawPixel(4, 1, RED);


	// You can also draw Pixels in paris, which is faster
    drawPixelPair(0, 2, RED);
	drawPixelPair(2, 2, GREEN);
	drawPixelPair(4, 2, BLUE);
    
	return 0;
}
