#ifndef SYSTEM_H
#define SYSTEM_H

/* System procedures */
extern void __fastcall__ setHiRes(unsigned char);
extern void __fastcall__ waitVSync(void);
extern void __fastcall__ waitStart(void);
extern void __fastcall__ waitFrames(unsigned char);
extern unsigned char __fastcall__ readGamepad(unsigned char);
extern unsigned char __fastcall__ readKeyboard(unsigned char);
extern void __fastcall__ halt(void);
extern void __fastcall__ calculate_coords(void*);
extern unsigned char __fastcall__ read_keyboard_row(unsigned char);
extern unsigned char __fastcall__ get_bit(unsigned char value, unsigned char number);
extern void __cdecl__ addBCD(long*, long*);
extern void __cdecl__ subBCD(long*, long*);
extern void __fastcall__ render_image(void*);
extern void __fastcall__ getBuildVersion(char*);
extern void __fastcall__ random_init(int);
extern unsigned char __fastcall__ random(void);
extern void __fastcall__ clear_screen(void);

// Gamepad keys
#define BUTTON_A 0x80
#define BUTTON_START 0x40
#define BUTTON_B 0x20
#define BUTTON_SELECT 0x10
#define BUTTON_UP 0x08
#define BUTTON_LEFT 0x04
#define BUTTON_DOWN 0x02
#define BUTTON_RIGHT 0x01

#define BLACK 0x00
#define GREEN 0x11
#define RED 0x22
#define ORANGE 0x33
#define PHARMACY_GREEN 0x44
#define LIME 0x55
#define MYSTIC_RED 0x66
#define YELLOW 0x77
#define BLUE 0x88
#define DEEP_SKY_BLUE 0x99
#define MAGENTA 0xaa
#define LAVENDER_ROSE 0xbb
#define NAVY_BLUE 0xcc
#define CIAN 0xdd
#define PINK_FLAMINGO 0xee
#define WHITE 0xff

// Keyboard
#define KEY_SPACE 0X80
#define KEY_INTRO 0X40
#define KEY_SHIFT 0X20
#define KEY_P 0X10
#define KEY_0 0X08
#define KEY_A 0X04
#define KEY_Q 0X02
#define KEY_1 0X01



#endif
