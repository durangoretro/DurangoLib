/* Copyright 2023 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file qgraph.h Graphics Definition Header File **/
#ifndef _QGRAPHH
#define _QGRAPHH

/* type definitions */
/**
 * byte definition correspond to a 8 bit (1 byte) data variable.
*/
typedef unsigned char byte;
/**
 * word type definition corresponde to 16 bit (2 bytes) data variable.
*/
typedef unsigned short word;

/**
 * Rectangle Struct
*/
typedef struct{
    byte x, y;
    word mem;
    byte color;
    byte width, height;
} rectangle;

/**
 * Brick Struct
*/
typedef struct{
    byte x, y;
    word mem;
    byte color;
    byte width, height;
    byte enabled;
    byte x2,y2;
} brick;

/**
 * Ball Struct
*/
typedef struct{
    byte x,y;
    word mem;
    byte color;
    byte vx, vy;
} ball;



/* Draw procedures */
/**
 * Fill the entire Screen
 * 
 * @deprecated this function is deprecated
 * 
 * @param color color to print
*/
extern void __fastcall__ fillScreen(byte color);
extern void __fastcall__ drawBall(void*);
extern void __fastcall__ moveBall(void*);
extern void __fastcall__ cleanBall(void*);
extern void __fastcall__ moveRight(void*);
extern void __fastcall__ moveLeft(void*);

#endif
