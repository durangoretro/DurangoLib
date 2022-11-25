/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file durango.h Main Header File **/

#ifndef _H_DURANGO
#define _H_DURANGO

/* TYPE DEFINITIONS */
typedef unsigned char byte;
typedef unsigned char u8;

/* PROCEDURES */
extern void __fastcall__ setHiRes(unsigned char);

/**
 * Fill the entire Screen of one color
 * @param color one of the 16 colors to print. Check video.h to see the 16 colors Macros.
 */
extern void __fastcall__ fillScreen(unsigned char);

/**
 * Draw a Pixel on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param color: color to use.
 */
extern void __cdecl__ drawPixel(unsigned char x, unsigned char y, unsigned char color);

/**
 * Draw a Rectangle on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param width: Rectangle width
 * @param height: Rectangle height
 * @param color: color to use.
 */
extern void __cdecl__ strokeRect(unsigned char x, unsigned char y, unsigned char width, unsigned char height, unsigned char color);

/**
 * Draw a filled Rectangle on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param width: Rectangle width
 * @param height: Rectangle height
 * @param color: color to use.
 */
extern void __cdecl__ fillRect(unsigned char x, unsigned char y, unsigned char width, unsigned char height, unsigned char color);


/* COLOURS */
/**
 * Black Color
 */
#define BLACK 0x00

/**
 * Geen Color
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
 * Navy Blue Color
 */
#define NAVY_BLUE 0xcc

/**
 * Cyan Color
 */
#define CIAN 0xdd

/**
 * Pink Color
 */
#define PINK_FLAMINGO 0xee

/**
 * White Color
 */
#define WHITE 0xff




/* GAMEPAD BUTTONS */
/**
 * BUTTON A 
 */
#define BUTTON_A 0x80

/**
 * BUTTON START 
 */
#define BUTTON_START 0x40


/**
 * BUTTON B
 */
#define BUTTON_B 0x20

/**
 * BUTTON SELECT
 */
#define BUTTON_SELECT 0x10

/**
 * BUTTON UP 
 */
#define BUTTON_UP 0x08

/**
 * BUTTON LEFT 
 */
#define BUTTON_LEFT 0x04

/**
 * BUTTON DOWN
 */
#define BUTTON_DOWN 0x02

/**
 * BUTTON RIGTH
 */
#define BUTTON_RIGHT 0x01


#endif

