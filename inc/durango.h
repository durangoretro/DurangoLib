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

/**
 * Draw a Line on Screen
 * @param x1: Start X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y1: Start Y Coord in pixels. The Y coordinate is from up to Down.
 * @param x2: End X Coord.
 * @param y2: End Y Coord
 * @param color: color to use.
 */
extern void __cdecl__ drawLine(unsigned char x1, unsigned char y1, unsigned char x2, unsigned char y2, unsigned char color);

/**
 * Draw a Circle on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param radio: Radio size
 * @param color: color to use.
 */
extern void __cdecl__ drawCircle(unsigned char x, unsigned char y, unsigned char radio, unsigned char color);


/**
 * Init conio lib. Should be called once before any conio operation, and
 * after any change in video mode register.
 */
extern void __fastcall__ conio_init(void);

/**
 * Print string
 * @param text null terminated char sequence.
 */
extern void __fastcall__ printf(char* text);

/**
 * Set up font used in conio. Should be called before any conio operation.
 * @param font pointer to font.
 */
extern void __fastcall__ set_font(void* font);


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

