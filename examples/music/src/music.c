/*
 * Hello Durango
 * To manually build:
 * make && make -C examples/hello_durango
 * NOTE: Requires rescomp v 1.0.1 to compile.
 */

#include <durango.h>
#include "melody.h"

int main(){
	
	//Erase Screen
	drawFullScreen(BLACK);
	//print String on Screen
	printStr(10,10,font,WHITE,BLACK,"Press A to Play Music");
	
    while(1){
		//Read Gamepad value
		gamepad=readGamepad(GAMEPAD_1);
		// if Button A is pressed on Gamepad 1
		if(gamepad & BUTTON_A){
			//Play Melody
			playMelody(melody);
		}
		waitVSync();
	}
	return 0;
}
