/*
 * Figures: Draw Example Figures
 * To manually build:
 * make && make -C examples/figures
 */
#include <durango.h>

int main(){
    //eraseScreen
	drawFullScreen(BLACK);
    //Draw Fill Rects
    drawFillRect(5,5,20,40,PHARMACY_GREEN);
    drawFillRect(26,5,40,20,ORANGE);
    drawFillRect(26,25,40,20,CIAN);

    //Draw Circles
    drawCircle(80,15,10,NAVY_BLUE);
    drawCircle(80,45,10,MYSTIC_RED);

    //Horizontal Lines
    drawLine(10,80,115,80,PINK_FLAMINGO);
    drawLine(10,110,115,110,PINK_FLAMINGO);

    //Vertical Lines
    drawLine(40,65,40,120,PINK_FLAMINGO);
    drawLine(80,65,80,120,PINK_FLAMINGO);

    //Draw Circle
    drawCircle(60,95,10,LAVENDER_ROSE);
    //Draw Cross
    drawLine(35,85,15,105,LAVENDER_ROSE);
    drawLine(15,85,35,105,LAVENDER_ROSE);

    while (1)
    {
        //Wait until Vsync
        waitVSync();
    }
    
    return 0;
}