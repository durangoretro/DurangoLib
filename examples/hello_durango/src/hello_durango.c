/*
 * Hello Durango
 * To manually build:
 * make && make -C examples/hello_durango
 */

#include <durango.h>

int main(){
	// Draw some pixels
	drawPixel(0, 0, ORANGE);
	drawPixel(1, 0, YELLOW);
	drawPixel(2, 0, LAVENDER_ROSE);
	drawPixel(3, 0, CIAN);
	drawPixel(4, 0, PINK_FLAMINGO);
	drawPixel(5, 0, WHITE);


	// You can also draw Pixels in paris, which is faster
    drawPixelPair(0, 1, RED);
	drawPixelPair(2, 1, GREEN);
	drawPixelPair(4, 1, BLUE);
    
	return 0;
}
