/* Copyright 2023 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file system.h System Calls Header File **/
#ifndef SYSTEM_H
#define SYSTEM_H

/* System procedures */
/**
 * Set High Res Mode
*/
extern void __fastcall__ setHiRes(unsigned char);

/**
 * Wait until next VSync Interruption
*/
extern void __fastcall__ waitVSync(void);

/**
 * Wait Until A button is pressed (action Button on Gamepad or Space/Intro on KeyBoard).
*/
extern void __fastcall__ waitButton(void);

/**
 * Wait until the Start Button (or enter button) is pressed.
*/
extern void __fastcall__ waitStart(void);

/**
 * Wait a number of frames (a number of VSync interruptions).
 * @param frames the number of frames to wait.
*/
extern void __fastcall__ waitFrames(byte);

/**
 * Read a Gamepad and returns the buttons pressed
 * @param gamepad gamepad to read.
 * @return value with the buttons pressed.
 * @see @link{GAMEPAD_1} or @link{GAMEPAD_2}
*/
extern unsigned char __fastcall__ readGamepad(unsigned char);

/**
 * read from KeyBoard
*/
extern unsigned char __fastcall__ readKeyboard(unsigned char);

/** Stops Durango Execution*/
extern void __fastcall__ halt(void);

extern void __fastcall__ calculate_coords(void*);
extern unsigned char __fastcall__ read_keyboard_row(unsigned char);
extern unsigned char __fastcall__ get_bit(unsigned char value, unsigned char number);
/**
 * adds two BCD numbers as long.
 * Add te second number to the first number
 * @param a pointer to first number and the result number
 * @param b pointer to second number
*/
extern void __cdecl__ addBCD(long*, long*);

/**
 * substract two BCD numbers as long.
 * substract te second number to the first number
 * @param a pointer to first number and the result number
 * @param b pointer to second number
*/
extern void __cdecl__ subBCD(long*, long*);

/**
 * Render an image Resource.
 * @param resource Resource Image.
 * @see Rescomp for more information.
*/
extern void __fastcall__ render_image(void*);

/**
 * Get the current Build Version. This version is getted from Rom Header signature
 * @param buffer char buffer to store the build vesion
 * */
extern void __fastcall__ getBuildVersion(char*);

/**
 * Init Random Seed
 * @param seed Random Seed number
*/
extern void __fastcall__ random_init(int);

/**
 * return a new Random number based on init seed.
 * @return new Random number
*/
extern unsigned char __fastcall__ random(void);

/**
 * Clear all Screen
*/
extern void __fastcall__ clear_screen(void);

// Gamepads 

/**
 * Player 1 Gamepad
*/
#define GAMEPAD_1 0

/**
 * Player 2 Gamepad
*/
#define GAMEPAD_2 1

// Gamepad keys
/**
 * Gampead A Button
*/
#define BUTTON_A 0x80
/**
 * Gamepad Start Button
*/
#define BUTTON_START 0x40
/**
 * Gamepad B Button
*/
#define BUTTON_B 0x20
/**
 * Gamepad Select Button
*/
#define BUTTON_SELECT 0x10
/**
 * Gamepad Up Button
*/
#define BUTTON_UP 0x08
/**
 * Gamepad Left Button
*/
#define BUTTON_LEFT 0x04
/**
 * Gamepad Down Button
*/
#define BUTTON_DOWN 0x02
/**
 * Gamepad Right Button
*/
#define BUTTON_RIGHT 0x01

//Colours

/**
 * Black
*/
#define BLACK 0x00
/**
 * Green
*/
#define GREEN 0x11
/**
 * Red
*/
#define RED 0x22
/**
 * Orange
*/
#define ORANGE 0x33
/**
 * Pharmacy Green
*/
#define PHARMACY_GREEN 0x44
/**
 * Lime
*/
#define LIME 0x55
/**
 * Mystic Red
*/
#define MYSTIC_RED 0x66
/**
 * Yellow
*/
#define YELLOW 0x77
/**
 * Blue
*/
#define BLUE 0x88
/**
 * Deep Sky Blue
*/
#define DEEP_SKY_BLUE 0x99
/**
 * Magenta
*/
#define MAGENTA 0xaa
/**
 * Lavender Rose
*/
#define LAVENDER_ROSE 0xbb
/**
 * Navy Blue
*/
#define NAVY_BLUE 0xcc

#define CYAN 0xdd

/**
 * Cyan
 * @deprecated use CYAN
*/
#define CIAN CYAN
/**
 * Pink Flamingo
*/
#define PINK_FLAMINGO 0xee
/**
 * White
*/
#define WHITE 0xff

// Keyboard
/**
 * Key Space
*/
#define KEY_SPACE 0X80
/**
 * Key Intro
*/
#define KEY_INTRO 0X40
/**
 * Key Shift
*/
#define KEY_SHIFT 0X20
/**
 * Key P
*/
#define KEY_P 0X10
/**
 * Key_0
*/
#define KEY_0 0X08
/**
 * Key_A
*/
#define KEY_A 0X04
/**
 * Key_Q
*/
#define KEY_Q 0X02
/**
 * Key_1
*/
#define KEY_1 0X01

/**
 * Allow to get one Color by Index
*/
int COLOR_BY_INDEX[]={BLACK,GREEN,RED,ORANGE,PHARMACY_GREEN,LIME,MYSTIC_RED,
                      YELLOW,BLUE, DEEP_SKY_BLUE,MAGENTA,LAVENDER_ROSE,NAVY_BLUE,CYAN,PINK_FLAMINGO,WHITE};
#endif
