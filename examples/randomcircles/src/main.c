/*
 * Show Random Circles in Screen
 * To manually build:
 * make && make -C examples/random_circles
 */

#include <durango.h>


int main(){
	int x,y,ratio,color;
    random_init(1122);

	while(1) {
		
        drawFullScreen(BLACK);
        x=random()*128;
        y=random()*128;
        ratio=10+random()*10;
        color = random()*16;

        drawCircle(x,y,ratio,COLOR_BY_INDEX[color]);
		// Wait for VSYNC
        waitVSync();
	}
	
	return 0;
}
