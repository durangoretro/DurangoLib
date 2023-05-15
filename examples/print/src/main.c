/*
 * print: print text on screen
 * To manually build:
 * make && make -C examples/print
 */

#include <durango.h>

int main(){
	//Erase Screen
	drawFullScreen(BLACK);
	//print String on Screen
	printStr(10,10,default_font,WHITE,BLACK,"Hello World");

	while(1){
		//Wait until VSync
		waitVSync();
	}
	return 0;
}
