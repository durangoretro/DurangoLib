/* Copyright 2023 Durango Computer Team

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

/** @file qgraph.h Graphics Definition Header File **/
#ifndef SPRITES_H
#define SPRITES_H

/**
 * Sprite Struct. Allow to store information about a Sprite.
 * <p>properties:</p>
 * <ul>
 * <li>X: position of Sprite in pixels.
 * <li>Y: Posiition of Sprite in pixels.
 * <li>mem: Position of the Sprite in memory
 * <li>width: Width of the Sprite.
 * <li>Height: Hegiht of the Sprite.
 * <li>rosurce: Pointer to the Resource
 * 
 * <b>NOTE</b>: The Sprite must be compiled with Rescomp.
*/
typedef struct{
    unsigned char x, y;
    unsigned short mem;
    unsigned char width, height;
    void* resource;
} sprite;

/**
 * Load a BackGround
 * @param resource. Background Resource pointer.
 * For more information to create the BackGround pointer please see Rescomp.
*/
extern void __fastcall__ load_background(void*);
/**
 * Clear the Screen
*/
extern void __fastcall__ clrscr(void);
/**
 * Draw a Sprite.
 * @param sprite: Sprite Struct
*/
extern void __fastcall__ draw_sprite(void*);
/**
 * Move Sprite to Right
*/
extern void __fastcall__ move_sprite_right(void*);
/**
 * Move Sprite to Left
*/
extern void __fastcall__ move_sprite_left(void*);
/**
 * Move Sprite Down
*/
extern void __fastcall__ move_sprite_down(void*);
/**
 * Move Sprite to Up
*/
extern void __fastcall__ move_sprite_up(void*);
/**
 * Clean a Sprite from Screen
*/
extern void __fastcall__ clean_sprite(void*);
/**
 * Stamp a Sprite
*/
extern void __fastcall__ stamp_sprite(void*);
/**
 * Check Two Sprites collision
*/
extern char __cdecl__ check_collisions(void*, void*);

#endif
