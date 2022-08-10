/*
 * Hello Durango
 * To manually build:
 *  Use Makefile after compile the lib:
 *  cd ../..
 *  make all
 *  cd examples/fillscreen
 *  make
 */

#include <durango.h>

int main(){
	char text[10]={12, "Hello, world!", 0};
	unsigned char i;
	
	while (text[i]) {
		_conio(text[i]);
		i++;
	}
    
	return 0;
}
