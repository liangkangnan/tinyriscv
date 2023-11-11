#ifndef __G2048_H
#define __G2048_H

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "../LCD/lcd.h"
#include "../LCD/lcd_init.h"


enum G2048Status{G2048Normal,G2048DEAD,G2048ESC,G2048Win};


typedef struct G2024{
    int _G2048Data[4][4]; 
	enum G2048Status _G2048Status;
	int _SleepTime;
    int _G2048Scoe;
}G2048,*pG2048;


void g2048_init(pG2048 p2048);
int g2048_run(pG2048 p2048);
void g2048_show(pG2048 p2048);


#endif
