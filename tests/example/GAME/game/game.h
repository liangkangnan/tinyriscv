#ifndef __GAME_H
#define __GAME_H

#include "snake.h"
#include "g2048.h"

#define GAMEMAP_X 30
#define GAMEMAP_Y 50
#define GAMEMAP_W 180
#define GAMEMAP_H 180
#define GAMEPixel 4

enum GAME_SEL{_MENU,_SNAKE,_G2048,_TANK};

enum GAME_SEL Last_game_model;
enum GAME_SEL game_model;
//int gamestate; //DEAD:0 NORMAL:1  SAVE:2
enum GAME_SATET{NORMAL,DEAD,SAVE};//DEAD:0 NORMAL:1  SAVE:2

enum GAME_SATET game_state[2];//SNAKE,G2048
int gamestate;
int menustate;

Snake snakefile;
G2048 g2048file;

uint8_t GAME_But[16];//{SELECT,1,2,START,LR_W,LR_R,LR_D,LR_L,L2,R2,L1,R1,RR_W,RR_R,RR_D,RR_L}


void get_control();
void game_init();
int game_run();
void game_show();

#endif