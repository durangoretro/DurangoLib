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

#endif
