/*
 * Hello Durango
 * To manually build:
 * make && make -C examples/hello_durango
 */

#include <durango.h>

int main(){
	drawFullScreen(WHITE);
	
	
	// Draw some pixels
	drawPixel(0, 0, ORANGE);
	drawPixel(2, 0, LAVENDER_ROSE);
	drawPixel(5, 0, RED);
	
	drawPixel(1, 1, ORANGE);
	drawPixel(3, 1, LAVENDER_ROSE);
	drawPixel(4, 1, RED);
    while(1){

		waitVSync();
	}
	return 0;
}
