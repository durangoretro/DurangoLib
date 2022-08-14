/*
 * Hello Durango
 * To manually build:
 *  Use Makefile after compile the lib:
 *  cd ../..
 *  make all
 *  cd examples/fillscreen
 *  make
 * 
 * 
   cc65 -I ../../../inc --cpu 6502 conio.c -o conio.s && ca65 -t none conio.s -o conio.o
   ld65 -C ../../../cfg/durango.cfg conio.o ../../../bin/dlib.o ../../../bin/8x8.o ../../../bin/conio.o ../../../bin/interrupt.o ../../../bin/wait.o ../../../bin/vectors.o ../../../bin/sbc.lib -o conio.bin

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
