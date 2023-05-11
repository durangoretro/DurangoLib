/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file qgraph.h Graphics Definition Header File **/
#ifndef _QGRAPHH
#define _QGRAPHH


// Colours
/**
 * Black Color
*/
#define BLACK 0x00
/**
 * Green Color
*/
#define GREEN 0x11
/**
 * Red Color
*/
#define RED 0x22
/**
 * Orange Color
*/
#define ORANGE 0x33
/**
 * Pharmacy Green Color
*/
#define PHARMACY_GREEN 0x44
/**
 * Lime Color
*/
#define LIME 0x55
/**
 * Mystic Red Color
*/
#define MYSTIC_RED 0x66
/**
 * Yellow Color
*/
#define YELLOW 0x77
/**
 * Blue Color
*/
#define BLUE 0x88
/**
 * Deep Sky Blue Color
*/
#define DEEP_SKY_BLUE 0x99
/**
 * Magenta Color
*/
#define MAGENTA 0xaa
/**
 * Lavender Rose Color
*/
#define LAVENDER_ROSE 0xbb
/**
 * Navy Color
*/
#define NAVY_BLUE 0xcc
/**
 * Cian Color
*/
#define CIAN 0xdd
/**
 * Pink Flamingo Color
*/
#define PINK_FLAMINGO 0xee

/**
 * White Color
*/
#define WHITE 0xff

// Gamepad keys
/**
 * Gamepad Button A
*/
#define BUTTON_A 0x80
/**
 * Gamepad Button Start
*/
#define BUTTON_START 0x40
/**
 * Gamepad Button B
*/
#define BUTTON_B 0x20
/**
 * Gamepad Button Select
*/
#define BUTTON_SELECT 0x10
/**
 * Gamepad Button Up
*/
#define BUTTON_UP 0x08
/**
 * Gamepad Button Left
*/
#define BUTTON_LEFT 0x04
/**
 * Gamepad Button dowm
*/
#define BUTTON_DOWN 0x02
/**
 * Gamepad Button right
*/
#define BUTTON_RIGHT 0x01

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
