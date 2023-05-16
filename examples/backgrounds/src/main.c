/*
 * Background: Draw Background Example
 * To manually build:
 * make && make -C examples/figures
 */
#include<durango.h>
//Import Resource compiled with Rescomp
#include "background.h"

int main(){
    //draw Full Screen
    drawFullScreen(BLACK);
    //Load background
    load_background(back1);
    //Clear Screen and update buffer
    clrscr();
    while(1){
        //Wait VSync
        waitVSync();
    }
    return 0;
}