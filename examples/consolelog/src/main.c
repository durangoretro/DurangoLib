/*
 * Console Log: Show messages using PSV
 * you can see this messages using nanolink and nanoserver on raspberry pi
 * or using perdita console.
 * To manually build:
 * make && make -C examples/console_log
 */

//include durango lib
#include <durango.h>

int main(){
    word a;
    int i=145;
    //Show an string on PSV console
    consoleLogStr("Hello PSV\n");
    a=20;
    //SHow a Word in 16 bit hex format
    consoleLogWord(a);
    //Show one Character(break line char)
    consoleLogChar('\n');
    
    while(1){
        //wait VScreen
        waitVSync();
    }
    return 0;
}