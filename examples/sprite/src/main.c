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
#include "sprite2.h"
#include "sprite3.h"

//defines
#define RIGHT 0
#define LEFT -1

#define UP 2
#define DOWN -2

//Global Variables
sprite ghost;
sprite greenghost;
sprite pinkghost;
int direction = RIGHT;
int directionGreen = UP;
int directionPink=DOWN;
//Function Prototypes
void updateGhost(sprite *);
void updateGreenGhost(sprite *);
void updatePinkGhost(sprite *);

int main(){

    //Init Sprite
    ghost.x=53;
    ghost.y=55;
    ghost.width=10;
    ghost.height=10;
    ghost.resource=&sprite_0_0;
    //Init green Sprite
    greenghost.x=90;
    greenghost.y=55;
    greenghost.width=10;
    greenghost.height=10;
    greenghost.resource=&sprite2_0_0;

    //Init Pink Ghost
    pinkghost.x=27;
    pinkghost.y=55;
    pinkghost.width=10;
    pinkghost.height=10;
    pinkghost.resource=&sprite3_0_0;
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
    //Draw another Sprite
    draw_sprite(&greenghost);
    //Draw Pink Ghost
    draw_sprite(&pinkghost);
    while(1){
        //Update Ghost Position
        updateGhost(&ghost);
        updateGreenGhost(&greenghost);
        updatePinkGhost(&pinkghost);
        //Wait VSync
        waitVSync();
    }
    return 0;
}

void updateGreenGhost(sprite * ghost){
 //If Ghost is under limit move down
    if(ghost->y<20){
      directionGreen=DOWN;
    }else{
        //Is Ghost is upper Limit move Right
        if(ghost->y>74){
           directionGreen=UP;
        }
    }
    //if direction is down(<0)
    if(directionGreen<0){
        //move sprite down
        move_sprite_down(ghost);
    }else{
        //move Sprite up
        move_sprite_up(ghost);
    }
}

void updatePinkGhost(sprite * ghost){
 //If Ghost is under limit move down
    if(ghost->y<20){
      directionPink=DOWN;
    }else{
        //Is Ghost is upper Limit move Right
        if(ghost->y>74){
           directionPink=UP;
        }
    }
    //if direction is down(<0)
    if(directionPink<0){
        //move sprite down
        move_sprite_down(ghost);
    }else{
        //move Sprite up
        move_sprite_up(ghost);
    }
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
    //if direction is left(<0)
    if(direction<0){
        //move sprite left
        move_sprite_left(ghost);
    }else{
        //move Sprite right
        move_sprite_right(ghost);
    }
}