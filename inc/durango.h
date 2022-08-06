#ifndef _H_DURANGO
#define _H_DURANGO

#include "video.h"

/* Log procedures */
// Log hex value in emulator
extern void __fastcall__ consoleLogHex(unsigned char value);
// Log char value in emulator
extern void __fastcall__ consoleLogChar(unsigned char value);
// Log string in emulator
extern void __fastcall__ consoleLogStr(char *str);

/* Sync procedures */
// Wait for vsync time
extern void __fastcall__ waitVsync(void);
// Wait for n frames
extern void __fastcall__ waitFrames(unsigned char frames);

/* Draw procedures */
// Fill screen with solid color
extern void __fastcall__ fillScreen(unsigned char color);
// Draw two pixels in screen
extern void __cdecl__ drawPixelPair(unsigned char x, unsigned char y, unsigned char color);
// Draw rect in screen
extern void __cdecl__ drawRect(unsigned char x, unsigned char y, unsigned char width, unsigned char height, unsigned char color);


#endif
