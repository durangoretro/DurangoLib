#ifndef _H_VIDEO
#define _H_VIDEO

#define HIRES 0X80
#define INVERT 0X40
#define SCREEN_0 0x00
#define SCREEN_1 0x10
#define SCREEN_2 0x20
#define SCREEN_3 0x30
#define RGB 0x08
#define LED 0x04
#define NEGRO 0x00
#define VERDE 0x11
#define ROJO 0x22
#define NARANJA 0x33
#define BOTELLA 0x44
#define LIMA 0x55
#define LADRILLO 0x66
#define AMARILLO 0x77
#define AZUL 0x88
#define CELESTE 0x99
#define MAGENTA 0xaa
#define ROSITA 0xbb
#define AZUR 0xcc
#define CIAN 0xdd
#define FUCSIA 0xee
#define BLANCO 0xff

#define VIDEO_MEM (unsigned int*)0xdf80

typedef struct{
    unsigned char x, y, color;
} pixel_pair;


extern void __fastcall__ setVideoMode(char mode);


#endif
