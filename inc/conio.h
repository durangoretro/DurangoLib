
/**
 * Init conio lib. Should be called once before any conio operation, and
 * after any change in video mode register.
 */
extern void __fastcall__ conio_init(void);

/**
 * Print string
 * @param text null terminated char sequence.
 */
extern void __fastcall__ printf(char* text);

/**
 * Set up font used in conio. Should be called before any conio operation.
 * @param font pointer to font.
 */
extern void __fastcall__ set_font(void* font);


