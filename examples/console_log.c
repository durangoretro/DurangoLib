/*
 * Hello Durango
 * To manually build:
 * cc65 -I ../inc --cpu 6502 console_log.c -o console_log.s
 * ca65 -t none console_log.s -o console_log.o
 * ld65 -C ../cfg/durango16k.cfg console_log.o ../bin/vectors.o ../bin/durango.lib ../bin/sbc.lib -o console_log.bin
 */

#include <durango.h>

int main(){
	// Log hex value
	consoleLogHex(0x11);
	consoleLogHex(0x22);
	consoleLogHex(0x33);

	// Log character
	consoleLogChar('a');
	consoleLogChar('b');
	consoleLogChar('c');

	// Log string
	consoleLogStr("Hello Durango\n");
    
	return 0;
}
