#ifndef PSV_H
#define PSV_H

/* Debug procedures */
extern void __fastcall__ consoleLogHex(unsigned char value);
extern void __fastcall__ consoleLogWord(unsigned short value);
extern void __fastcall__ consoleLogBinary(unsigned char value);
extern void __fastcall__ consoleLogDecimal(unsigned char value);
extern void __fastcall__ consoleLogInt(int value);
extern void __fastcall__ consoleLogHex16(int value);
extern void __fastcall__ consoleLogChar(unsigned char);
extern void __fastcall__ consoleLogStr(char *str);
extern void __fastcall__ startStopwatch(void);
extern void __fastcall__ stopStopwatch(void);
extern void __fastcall__ psvDump(void);

#endif
