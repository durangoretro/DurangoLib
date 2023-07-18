/* Copyright 2022 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file qglyph.h Print Utilities Header File **/

#ifndef GLYPH_H
#define GLYPH_H

/**
 * print a Number as a BCD in screen.
 * @param x X Position in pixels.
 * @param y Y Position in pixels.
 * @param font Pointer to Font.
 * @param color Color to Print the Text.
 * @param paper Color to print the background (paper).
 * @param value Long Value to print
*/
extern void __cdecl__ printBCD(unsigned char x, unsigned char y, void* font, unsigned char color, unsigned char paper, long value);

/**
 * print a String in screen.
 * @param x X Position in pixels.
 * @param y Y Position in pixels.
 * @param font Pointer to Font.
 * @param color Color to Print the Text.
 * @param paper Color to print the background (paper).
 * @param value String Value to print
*/
extern void __cdecl__ printStr(unsigned char x, unsigned char y, void* font, unsigned char color, unsigned char paper, char *value);
/**
 * Read String
 * @param x x coord in pixels
 * @param y y coord in pixels
 * @param font pointer to font data
 * @param color Color index. See system.h for more info
 * @param paper paper color index. See System.h for more info
 * @param value string value
 * @param max max length
*/
extern void __cdecl__ readStr(unsigned char x, unsigned char y, void* font, unsigned char color, unsigned char paper, char *value, char max);

#endif
