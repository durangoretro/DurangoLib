#include<durango.h>
#include "background.h"

int main(){

    drawFullScreen(BLACK);
    load_background(back1);
    while(1){
        waitVSync();
    }
    return 0;
}