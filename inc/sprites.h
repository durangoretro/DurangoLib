#ifndef SPRITES_H
#define SPRITES_H

typedef struct{
    unsigned char x, y;
    unsigned short mem;
    unsigned char width, height;
    void* resource;
} sprite;

extern void __fastcall__ load_background(void*);
extern void __fastcall__ clrscr(void);
extern void __fastcall__ draw_sprite(void*);
extern void __fastcall__ move_sprite_right(void*);
extern void __fastcall__ move_sprite_left(void*);
extern void __fastcall__ move_sprite_down(void*);
extern void __fastcall__ move_sprite_up(void*);
extern void __fastcall__ clean_sprite(void*);
extern void __fastcall__ stamp_sprite(void*);
extern char __cdecl__ check_collisions(void*, void*);

#endif
