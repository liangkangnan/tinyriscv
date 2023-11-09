#ifndef __MENU_H
#define __MENU_H

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "../LCD/lcd.h"
#include "../LCD/lcd_init.h"

enum MENU1_STATE{None1,IN1,SNAKE1,G20481,OUT1};
enum MENU2_1_STATE{None2_1,IN2_1,CONTINUE2_1,NEWGAME2_1,SOUT2_1,OUT2_1};
enum MENU2_2_STATE{None2_2,IN2_2,NEWGAME2_2,NSOUT2_2,OUT2_2};

uint8_t m1return;
uint8_t m2_1return;
uint8_t m2_2return;

enum MENU1_STATE menu1_state;
enum MENU2_1_STATE menu2_1_state;
enum MENU2_2_STATE menu2_2_state;

void MENU_init(void);
int menu_run();//0 continue 1 new 2 menu 3



#endif
