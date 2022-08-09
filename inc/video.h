/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file video.h Video specific Header File*/

#ifndef _H_VIDEO
#define _H_VIDEO

/**
 * HIGH RESOLUTION 256x256 Pixels GrayScale
 **/
#define HIRES 0X80

/**
 * Invert Colors
 */
#define INVERT 0X40

/**
 * Screen 0 Memory Space
 */
#define SCREEN_0 0x00

/**
 * Screen 1 Memory Space
 */
#define SCREEN_1 0x10

/**
 * Screen 2 Memory Space
 */
#define SCREEN_2 0x20

/**
 * Screen 3 Memory Space
 */
#define SCREEN_3 0x30

/**
 * RGB Mode 128x128 Pixels 16 Colours.
 */
#define RGB 0x08

/**
 * LED
 */
#define LED 0x04

//Colours

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



/**
 * Set the Video Mode
 * @param mode: Video Mode; receive the next values:
 * 
 * * HIRES: 256x256 pixeles grayscale.
 * * RGB: 128x128 pixeles 16 colurs.
 * 
 * Also, you can use a mask to ensure the Screen Memory Block Used
 * 
 * example: <pre>RGB | SCREEN_1</pre> -> RGB Mode at Screen Memory Block 1.
 * 
 * <strong>NOTE:</strong> By default RGB Mode and Screen 3 are used.
 */
extern void __fastcall__ setVideoMode(char mode);


#endif
