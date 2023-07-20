/* Copyright 2023 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.

Durango Project Web: https://www.durangoretro.com
*/

/** @file psv.h Virtual Serial Port Header File **/
#ifndef PSV_H
#define PSV_H

/* Debug procedures */

/**
 * Show in console a hex Value
 * @param value Hex Value
*/
extern void __fastcall__ consoleLogHex(unsigned char value);

/**
 * Show in console a Word Value (16 bit number).
 * @param value Word Value
*/
extern void __fastcall__ consoleLogWord(unsigned short value);

/**
 * Show in console a Binary Value (8 bit value).
 * @param value Binary Value 
*/
extern void __fastcall__ consoleLogBinary(unsigned char value);

/**
 * Show in console a Decimal Value
 * @param value Decimal Value
*/
extern void __fastcall__ consoleLogDecimal(unsigned char value);

/**
 * Show in console an Integer value
 * @param value Integer Value
*/
extern void __fastcall__ consoleLogInt(int value);

/**
 * Show in console an Integer in Hexadecimal Mode.
 * @param value Hexadecimal Integer
*/
extern void __fastcall__ consoleLogHex16(int value);

/**
 * Show in console a Character value.
 * @param value Character Value.
*/
extern void __fastcall__ consoleLogChar(unsigned char);

/**
 * SHow in console an String value
 * @param str String value
 *
*/
extern void __fastcall__ consoleLogStr(char *str);

/**
 * Console Log Signed Char
 * @param value value Char
*/
extern void __fastcall__ consoleLogSignedChar(char value);

/**
 * Console Log Long
 * @param value Long value
*/
extern void __fastcall__ consoleLogLong(long value);


/**
 * Start Stop Watch Mode
*/
extern void __fastcall__ startStopwatch(void);

/**
 * Stop Stop Watch Mode
*/
extern void __fastcall__ stopStopwatch(void);

/**
 * made a PSV Dump using nanolink or using Perdita.
 * This is used for save or load information
*/
extern void __fastcall__ psvDump(void);

#endif
