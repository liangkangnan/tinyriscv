#include "game.h"
#include "LCD.h"
#include "../PS2/PS2.h"
#include "menu.h"
#include "g2048.h"

void get_control()
{
    GetData();
    for (int i=0;i<16;i++) GAME_But[i]=All_But[i];
    delay_ms(100);
    GetData();
    for (int i=0;i<16;i++)
    {
        if (GAME_But[i] && All_But[i]) GAME_But[i]=1;
        else GAME_But[i]=0;
    }
}

void draw_game_icon()
{
    int icon_x=GAMEMAP_X+GAMEMAP_W/2-12*GAMEPixel;
    int icon_y=GAMEMAP_Y+GAMEMAP_H/2-16*GAMEPixel;
    for(int i=0;i<GAMEPixel;i++)
    {
        for(int j=0;j<GAMEPixel;j++)
        {
        LCD_DrawLine(icon_x+2*GAMEPixel+j,icon_y+0*GAMEPixel+i,icon_x+23*GAMEPixel+j,icon_y+0*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+4*GAMEPixel+j,icon_y+3*GAMEPixel+i,icon_x+21*GAMEPixel+j,icon_y+3*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+4*GAMEPixel+j,icon_y+3*GAMEPixel+i,icon_x+21*GAMEPixel+j,icon_y+3*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+4*GAMEPixel+j,icon_y+18*GAMEPixel+i,icon_x+21*GAMEPixel+j,icon_y+18*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+15*GAMEPixel+j,icon_y+22*GAMEPixel+i,icon_x+21*GAMEPixel+j,icon_y+22*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+1*GAMEPixel+j,icon_y+32*GAMEPixel+i,icon_x+24*GAMEPixel+j,icon_y+32*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+1*GAMEPixel+j,icon_y+28*GAMEPixel+i,icon_x+24*GAMEPixel+j,icon_y+28*GAMEPixel+i,GRAY);
        
        LCD_DrawLine(icon_x+25*GAMEPixel+j,icon_y+2*GAMEPixel+i,icon_x+25*GAMEPixel+j,icon_y+27*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+0*GAMEPixel+j,icon_y+2*GAMEPixel+i,icon_x+0*GAMEPixel+j,icon_y+27*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+3*GAMEPixel+j,icon_y+4*GAMEPixel+i,icon_x+3*GAMEPixel+j,icon_y+17*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+22*GAMEPixel+j,icon_y+4*GAMEPixel+i,icon_x+22*GAMEPixel+j,icon_y+17*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+24*GAMEPixel+j,icon_y+28*GAMEPixel+i,icon_x+24*GAMEPixel+j,icon_y+32*GAMEPixel+i,GRAY);
        LCD_DrawLine(icon_x+1*GAMEPixel+j,icon_y+28*GAMEPixel+i,icon_x+1*GAMEPixel+j,icon_y+32*GAMEPixel+i,GRAY);
        
        LCD_DrawPoint(icon_x+1*GAMEPixel+i,icon_y+1*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+24*GAMEPixel+i,icon_y+1*GAMEPixel+j,GRAY);

        LCD_DrawPoint(icon_x+8*GAMEPixel+i,icon_y+7*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+8*GAMEPixel+i,icon_y+8*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+15*GAMEPixel+i,icon_y+7*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+15*GAMEPixel+i,icon_y+8*GAMEPixel+j,GRAY);

        LCD_DrawPoint(icon_x+12*GAMEPixel+i,icon_y+7*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+12*GAMEPixel+i,icon_y+8*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+12*GAMEPixel+i,icon_y+9*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+12*GAMEPixel+i,icon_y+10*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+12*GAMEPixel+i,icon_y+11*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+11*GAMEPixel+i,icon_y+11*GAMEPixel+j,GRAY);

        LCD_DrawPoint(icon_x+3*GAMEPixel+i,icon_y+23*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+4*GAMEPixel+i,icon_y+23*GAMEPixel+j,GRAY);

        LCD_DrawPoint(icon_x+9*GAMEPixel+i,icon_y+13*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+10*GAMEPixel+i,icon_y+14*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+11*GAMEPixel+i,icon_y+14*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+12*GAMEPixel+i,icon_y+14*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+13*GAMEPixel+i,icon_y+14*GAMEPixel+j,GRAY);
        LCD_DrawPoint(icon_x+14*GAMEPixel+i,icon_y+13*GAMEPixel+j,GRAY);
        }
    }

}

void game_init()
{
    //Boot animation
    LCD_ShowString(88,0,"PBOX:",RED,WHITE,16,0);
    LCD_ShowString(0,40,"LCD_W:",RED,WHITE,16,0);
	LCD_ShowIntNum(48,40,LCD_W,3,RED,WHITE,16);
	LCD_ShowString(80,40,"LCD_H:",RED,WHITE,16,0);
	LCD_ShowIntNum(128,40,LCD_H,3,RED,WHITE,16);
    LCD_ShowString(0,40,"MAP_W:",RED,WHITE,16,0);
	LCD_ShowIntNum(48,40,GAMEMAP_W,3,RED,WHITE,16);
	LCD_ShowString(80,40,"MAP_H:",RED,WHITE,16,0);
	LCD_ShowIntNum(128,40,GAMEMAP_H,3,RED,WHITE,16);
    draw_game_icon();

    //delay_ms(5000);
    int flag=1;
    while(flag)
    {
        get_control();
        for (int i=0;i<16;i++)
        {
            if (GAME_But[i])flag=0;
        }   
    }
	//game_model=SNAKE;

	SnakeStart(&snakefile);
    g2048_init(&g2048file);
    MENU_init();
}



int game_run()
{
    get_control();
    LCD_ShowIntNum(128,8,GAME_But[4],1,RED,WHITE,12);
    LCD_ShowIntNum(112,20,GAME_But[7],1,RED,WHITE,12);
    LCD_ShowIntNum(144,20,GAME_But[5],1,RED,WHITE,12);
    LCD_ShowIntNum(128,32,GAME_But[6],1,RED,WHITE,12);
    //LCD_ShowIntNum(160,20,GAME_But[0],1,RED,WHITE,12);
    //LCD_ShowIntNum(180,20,GAME_But[3],1,RED,WHITE,12);
    switch(game_model)
    {
    case _MENU:
        menustate=menu_run();
        break;
    case _SNAKE:
        switch (game_state[0])
        {
        case DEAD:
            SnakeClean(&snakefile);
            game_model=_MENU;
            m1return=1;
            m2_1return=0;
            m2_2return=1;
            menu2_1_state=IN2_1;
            break;
        case NORMAL:
            gamestate=SnakeRun(&snakefile);
            if(gamestate==0)game_state[0]=NORMAL;
            else if(gamestate==1)game_state[0]=DEAD;
            else if(gamestate==2)game_state[0]=SAVE;
            break;
        case SAVE:
            game_model=_MENU;
            m1return=1;
            m2_1return=0;
            m2_2return=1;
            menu2_1_state=IN2_1;
            break;
        default:
            break;
        }
        break;
    case _G2048:
        switch (game_state[1])
        {
        case DEAD:
            g2048_init(&g2048file);
            game_model=_MENU;
            m1return=1;
            m2_1return=0;
            m2_2return=1;
            menu2_1_state=IN2_1;
            break;
        case NORMAL:
            gamestate=g2048_run(&g2048file);
            if(gamestate==0)game_state[1]=NORMAL;
            else if(gamestate==1)game_state[1]=DEAD;
            else if(gamestate==2)game_state[1]=SAVE;
            break;
        case SAVE:
            game_model=_MENU;
            m1return=1;
            m2_1return=0;
            m2_2return=1;
            menu2_1_state=IN2_1;
            break;
        default:
            break;
        }
        break;
    }
    
    return 0;
}

// void game_show()
// {
    

// }