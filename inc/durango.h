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

