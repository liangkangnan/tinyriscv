#include "menu.h"
#include "game.h"
#include "snake.h"
#include "../PS2/PS2.h"

void MENU_init()
{
	menu1_state=IN1;
	m1return=0;
	m2_1return=1;
	m2_2return=1;
}

int MENU1_RUN()
{
	switch(menu1_state)
	{
		case None1:
			return 0;
		case IN1:
			LCD_Fill(GAMEMAP_X, GAMEMAP_Y, GAMEMAP_X+GAMEMAP_W, GAMEMAP_Y+GAMEMAP_H, BROWN);
			delay_ms(2000);
			menu1_state=SNAKE1;
			LCD_ShowString(GAMEMAP_X+GAMEMAP_W/2-20,GAMEMAP_Y+GAMEMAP_H/2-24,"SNAKE",WHITE,BROWN,16,0);
			LCD_ShowString(GAMEMAP_X+GAMEMAP_W/2-20,GAMEMAP_Y+GAMEMAP_H/2+8,"G2048",WHITE,BROWN,16,0);
			LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-24," ",YELLOW,YELLOW,16,0);
			LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-24," ",YELLOW,YELLOW,16,0);
			delay_ms(1000);
			return 0;
		case SNAKE1:
			if(GAME_But[0]==1)
			{
				DISABLEPS2();
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-24," ",BROWN,BROWN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-24," ",BROWN,BROWN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2+8," ",YELLOW,YELLOW,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2+8," ",YELLOW,YELLOW,16,0);
				delay_ms(1000);
				menu1_state=G20481;
				return 0;
			}
			else if(GAME_But[3]==1)
			{
				DISABLEPS2();
				menu2_1_state=IN2_1;
				m2_1return=0;
				delay_ms(3000);
				return 1;
			}
			return 0;
		case G20481:
			if(GAME_But[0]==1)
			{
				DISABLEPS2();
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-24," ",YELLOW,YELLOW,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-24," ",YELLOW,YELLOW,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2+8," ",BROWN,BROWN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2+8," ",BROWN,BROWN,16,0);
				menu1_state=SNAKE1;
				delay_ms(1000);
				return 0;
			}
			else if(GAME_But[3]==1)
			{
				DISABLEPS2();
				menu2_1_state=IN2_1;
				m2_1return=0;
				delay_ms(3000);
				return 1;
			}
			return 0;
		default:
			return 0;
	}
	return 0;
}

int MENU2_1_RUN()
{
	switch(menu2_1_state)
	{
		case IN2_1:
			LCD_Fill(GAMEMAP_X+GAMEMAP_W/4-8,GAMEMAP_Y+GAMEMAP_H/4,GAMEMAP_W,GAMEMAP_H,GREEN);
			delay_ms(2000);
			menu2_1_state=CONTINUE2_1;
			LCD_ShowString(GAMEMAP_X+GAMEMAP_W/2-32,GAMEMAP_Y+GAMEMAP_H/2-32,"CONTINUE",WHITE,GREEN,16,0);
			LCD_ShowString(GAMEMAP_X+GAMEMAP_W/2-28,GAMEMAP_Y+GAMEMAP_H/2-8,"NEWGAME",WHITE,GREEN,16,0);
			LCD_ShowString(GAMEMAP_X+GAMEMAP_W/2-16,GAMEMAP_Y+GAMEMAP_H/2+16,"MENU",WHITE,GREEN,16,0);
			LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-32,"[",RED,RED,16,0);
			LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-32,"]",RED,RED,16,0);
			delay_ms(1000);
			return 0;
			break;
		case CONTINUE2_1:
			//LCD
			if(GAME_But[0]==1)
			{
				DISABLEPS2();
				menu2_1_state=NEWGAME2_1;
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-32," ",GREEN,GREEN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-32," ",GREEN,GREEN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-8,"[",RED,RED,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-8,"]",RED,RED,16,0);
				delay_ms(1000);
				return 0;
			}
			else if(GAME_But[3]==1)
			{
				DISABLEPS2();
				LCD_Fill(0, 0, 240, 280, WHITE);
				delay_ms(2000);
				switch(menu1_state)
				{
					case SNAKE1:
						DrawMap();
						game_state[0]=NORMAL;
						game_model=_SNAKE;
						snakefile._Status=NORMAL;
					case G20481:
						game_model=_G2048;
						game_state[1]=NORMAL;
						g2048file._G2048Status=G2048Normal;
						LCD_Fill(0, 0, 240, 280, WHITE);
						delay_ms(2000);
						g2048_show(&g2048file);
						break;
				}
				delay_ms(3000);
				return 1;
			}
			return 0;
			break;
		case NEWGAME2_1:
			//LCD
			if(GAME_But[0]==1)
			{
				DISABLEPS2();
				menu2_1_state=SOUT2_1;
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-8," ",GREEN,GREEN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-8," ",GREEN,GREEN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2+16,"[",RED,RED,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2+16,"]",RED,RED,16,0);
				delay_ms(1000);
				return 0;
			}
			else if(GAME_But[3]==1)
			{
				DISABLEPS2();
				switch(menu1_state)
				{
					case SNAKE1:
						game_model=_SNAKE;
						game_state[0]=NORMAL;
						SnakeClean(&snakefile);
						SnakeStart(&snakefile);
						LCD_Fill(0, 0, 240, 280, WHITE);
						delay_ms(2000);
						DrawMap();
						break;
					case G20481:
						g2048_init(&g2048file);
						game_model=_G2048;
						game_state[1]=NORMAL;
						LCD_Fill(0, 0, 240, 280, WHITE);
						delay_ms(2000);
						g2048_show(&g2048file);
						break;
				}
				return 2;
			}
			return 0;
		case SOUT2_1:
			if(GAME_But[0]==1)
			{
				DISABLEPS2();
				menu2_1_state=CONTINUE2_1;
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2-32," ",RED,RED,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2-32," ",RED,RED,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2-48,GAMEMAP_Y+GAMEMAP_H/2+16,"[",GREEN,GREEN,16,0);
				LCD_ShowChar(GAMEMAP_X+GAMEMAP_W/2+40,GAMEMAP_Y+GAMEMAP_H/2+16,"]",GREEN,GREEN,16,0);
				delay_ms(1000);
				return 0;
			}
			else if(GAME_But[3]==1)
			{
				DISABLEPS2();
				menu1_state=IN1;
				m1return=0;
				return 1;
			}
			return 0;
			break;
		default:
			return 0;
	}
	return 0;
}
//int MENU2_2_RUN();

int menu_run()
{
	if(!m1return){m1return=MENU1_RUN();return m1return;}
	if(!m2_1return){m2_1return=MENU2_1_RUN();return m2_1return;}
	//if(!m2_2return){m2_2return=MENU2_2_RUN();return m2_2return;}
	return 0;
}
