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
extern void __fastcall__ consoleLogHex(unsigned char value);
extern void __fastcall__ consoleLogWord(unsigned short value);
extern void __fastcall__ consoleLogBinary(unsigned char value);
extern void __fastcall__ consoleLogDecimal(unsigned char value);
extern void __fastcall__ consoleLogInt(int value);
extern void __fastcall__ consoleLogHex16(int value);
extern void __fastcall__ consoleLogChar(unsigned char);
extern void __fastcall__ consoleLogStr(char *str);
extern void __fastcall__ startStopwatch(void);
extern void __fastcall__ stopStopwatch(void);
extern void __fastcall__ psvDump(void);

#endif
