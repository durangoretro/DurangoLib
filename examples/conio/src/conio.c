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
	char text[15]={12, 'H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!', 0};
	unsigned char i;
	
	while (text[i]) {
		conio(text[i]);
		i++;
	}
    
	return 0;
}
