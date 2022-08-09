/*
 * Console log
 * To manually build:
 * make && make -C examples/console_log
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
