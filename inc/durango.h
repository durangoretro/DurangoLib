/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file durango.h Main Header File **/

#ifndef _H_DURANGO
#define _H_DURANGO

#include "video.h"

#define BUTTON_A 0x80
#define BUTTON_START 0x40
#define BUTTON_B 0x20
#define BUTTON_SELECT 0x10
#define BUTTON_UP 0x08
#define BUTTON_LEFT 0x04
#define BUTTON_DOWN 0x02
#define BUTTON_RIGHT 0x01

/**
 * Draw a Pixel on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param color: color to use. Check the video.h file for the macros for the 16 colors.
 */
extern void __cdecl__ drawPixel(unsigned char x, unsigned char y, unsigned char color);

/**
 * Draw a Pixel Pair on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param color: color to use. Check the video.h file for the macros for the 16 colors.
 */
extern void __cdecl__ drawPixelPair(unsigned char x, unsigned char y, unsigned char color);

/**
 * Wait until the Screen has been printed. That means that waits until the V Interruption.
 */
extern void __fastcall__ waitVsync(void);

/**
 * Wait until some frames has been printed
 * @param frames Number of frames to wait.
 */
extern void __fastcall__ waitFrames(unsigned char frames);

/**
 * Fill the entire Screen of one color
 * @param color one of the 16 colors to print. Check video.h to see the 16 colors Macros.
 */
extern void __fastcall__ fillScreen(unsigned char color);

/**
 * Send to the console log (using debug port or using emulator console). the current value as Hex
 *@param value value to send.
 */
extern void __fastcall__ consoleLogHex(unsigned char value);

/**
 * Send to the console log (using debug port or using emulator console). the current value as Char
 *@param value value to send.
 */
extern void __fastcall__ consoleLogChar(unsigned char value);

/**
 * Send to the console log (using debug port or using emulator console). the current value as String.
 *@param value value to send.
 */
extern void __fastcall__ consoleLogStr(char *str);

/**
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param width: Rectangle width
 * @param height: Rectangle height
 * @param color: color to use. Check the video.h file for the macros for the 16 colors.
 */
extern void __cdecl__ drawRect(unsigned char x, unsigned char y, unsigned char width, unsigned char height, unsigned char color);

/**
 * Read first gamepad.
 */
extern unsigned char __fastcall__ readGamepad1(void);
/**
 * Read second gamepad.
 */
extern unsigned char __fastcall__ readGamepad2(void);

#endif
