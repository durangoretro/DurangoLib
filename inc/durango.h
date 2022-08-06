#ifndef _H_DURANGO
#define _H_DURANGO

#include "video.h"

extern void __cdecl__ drawPixelPair(unsigned char x, unsigned char y, unsigned char color);
extern void __fastcall__ waitVsync(void);
extern void __fastcall__ waitFrames(unsigned short frames);
extern void __fastcall__ fillScreen(unsigned short color);
extern void __fastcall__ consoleLogHex(unsigned short value);
extern void __fastcall__ consoleLogChar(unsigned short value);
extern void __fastcall__ consoleLogStr(char *str);

#endif
