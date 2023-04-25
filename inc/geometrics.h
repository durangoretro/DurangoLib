#ifndef GEOMETRICS_H
#define GEOMETRICS_H


/**
 * Fill the entire Screen of one color
 * @param color one of the 16 colors to print. Check video.h to see the 16 colors Macros.
 */
extern void __fastcall__ drawFullScreen(unsigned char color);


/**
 * Draw a Pixel on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param color: color to use.
 */
extern void __cdecl__ drawPixel(unsigned char x, unsigned char y, unsigned char color);


/**
 * Draw a Rectangle on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param width: Rectangle width
 * @param height: Rectangle height
 * @param color: color to use.
 */
extern void __cdecl__ drawRect(unsigned char x, unsigned char y, unsigned char width, unsigned char height, unsigned char color);

/**
 * Draw a filled Rectangle on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param width: Rectangle width
 * @param height: Rectangle height
 * @param color: color to use.
 */
extern void __cdecl__ drawFillRect(unsigned char x, unsigned char y, unsigned char width, unsigned char height, unsigned char color);

/**
 * Draw a Line on Screen
 * @param x1: Start X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y1: Start Y Coord in pixels. The Y coordinate is from up to Down.
 * @param x2: End X Coord.
 * @param y2: End Y Coord
 * @param color: color to use.
 */
extern void __cdecl__ drawLine(unsigned char x1, unsigned char y1, unsigned char x2, unsigned char y2, unsigned char color);

/**
 * Draw a Rectangle on Screen
 * @param x: X Coord in pixels. The x coordinate is from left to Rigth.
 * @param y: Y Coord in pixels. The Y coordinate is from up to Down.
 * @param width: Rectangle width
 * @param height: Rectangle height
 * @param color: color to use.
 */
extern void __cdecl__ drawCircle(unsigned char x, unsigned char y, unsigned char radio, unsigned char color);


#endif
