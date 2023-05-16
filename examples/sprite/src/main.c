/*
 * Show Background and Sprite Example.
 * 
 * To manually build:
 * make && make -C examples/sprite
 */
#include <durango.h>
//import Resources. See Rescomp for more Information.
#include "background.h"
#include "sprite1.h"

//defines
#define RIGHT 0
#define LEFT -1

//Global Variables
sprite ghost;
int direction = RIGHT;
//Function Prototypes
void updateGhost(sprite *);

int main(){

    //Init Sprite
    ghost.x=53;
    ghost.y=55;
    ghost.width=10;
    ghost.height=10;
    ghost.resource=&sprite_0_0;
    //Draw Full Screen Black
    drawFullScreen(BLACK);
    //Load BackGround
    load_background(back1);
    //Update Screen
    clrscr();
    //Calculate Sprite Coords
    calculate_coords(&ghost);
    //Draw a new Sprite
    draw_sprite(&ghost);
    while(1){
        //Update Ghost Position
        updateGhost(&ghost);
        //Wait VSync
        waitVSync();
    }
    return 0;
}

//Update Ghost Function
void updateGhost(sprite * ghost){
    //If Ghost is under limit move Left
    if(ghost->x<54){
      direction=RIGHT;
    }else{
        //Is Ghost is upper Limit move Right
        if(ghost->x>65){
           direction=LEFT;
        }
    }

    if(direction<0){
        move_sprite_left(ghost);
    }else{
        move_sprite_right(ghost);
    }
}