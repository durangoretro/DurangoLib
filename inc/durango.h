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

/* IO procedures */
extern unsigned char __fastcall__ readGamepad1(void);
extern unsigned char __fastcall__ readGamepad2(void);

#endif
