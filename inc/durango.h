/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file durango.h Main Header File **/

#ifndef _H_DURANGO
#define _H_DURANGO

#include "video.h"

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
extern void __fastcall__ waitFrames(unsigned short frames);

/**
 * Fill the entire Screen of one color
 * @param color one of the 16 colors to print. Check video.h to see the 16 colors Macros.
 */
extern void __fastcall__ fillScreen(unsigned short color);

/**
 * Send to the console log (using debug port or using emulator console). the current value as Hex
 *@param value value to send.
 */
extern void __fastcall__ consoleLogHex(unsigned short value);

/**
 * Send to the console log (using debug port or using emulator console). the current value as Char
 *@param value value to send.
 */
extern void __fastcall__ consoleLogChar(unsigned short value);

/**
 * Send to the console log (using debug port or using emulator console). the current value as String.
 *@param value value to send.
 */
extern void __fastcall__ consoleLogStr(char *str);

#endif
