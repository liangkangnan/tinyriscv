#include <stdint.h>

#include "../include/gpio.h"
#include "../include/utils.h"
#include "../include/spi.h"

#include "LCD/lcd_init.h"
#include "LCD/lcd.h"
#include "game/snake.h"
#include "game/game.h"
#include "../include/timer.h"
#include "PS2/PS2.h"

//#include "LCD/pic.h"

static volatile uint32_t count;

// cmd = {0x01,0x42,0x00};  // �����������
// PS2data= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};   //�洢�ֱ���������
// XY= {500,500,500,500};  //ҡ��ģ��ֵ
// All_But= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}; 

uint8_t t2=0;

int main(void)
{
	u8 i,j;
	int GameState=0;
	uint8_t t=0;
	
	LCD_Init();//LCD��ʼ��
	PS2_init();
	LCD_Fill(0,0,LCD_W,LCD_H,WHITE);


	delay_ms(2000);
	LCD_Fill(0,0,LCD_W,LCD_H,WHITE);

	game_init();
	while(1)
	{
	GameState=game_run();	
	if(t>=0&&t<51)LCD_ShowString(30,250,"*       ",BLACK,WHITE,16,0);
	else if(t>=51&&t<102)LCD_ShowString(30,250,"**      ",BLACK,WHITE,16,0);
	else if(t>=102&&t<153)LCD_ShowString(30,250,"***     ",BLACK,WHITE,16,0);
	else if(t>=153&&t<204)LCD_ShowString(30,250,"****    ",BLACK,WHITE,16,0);
	else LCD_ShowString(30,250,"*****",BLACK,WHITE,16,0);
	LCD_ShowIntNum(120,250,t,3,RED,WHITE,12);
	LCD_ShowIntNum(150,250,PS2STATE,1,RED,WHITE,12);
	
	t++;
	}


	// count = 0;
	//int count1=0;
	// TIMER0_REG(TIMER0_VALUE) = 500000;  // 10ms period
    // TIMER0_REG(TIMER0_CTRL) = 0x07;     // enable interrupt and start timer



	// while (1) {
    //     // 500ms
    //     // if (count == 50) {
    //     //     count = 0;
	// 	// 	count1++;
    //     //     LCD_ShowIntNum(40,40,count1,3,RED,WHITE,16);
    //     // }
	// 	count1++;
    //     LCD_ShowIntNum(120,120,count1,3,RED,WHITE,16);


	// 	// spi2_set_ss(0);

	// 	// PS2data[0]=spi2_write_read_byte(0b10000000);
	// 	// delay_us(10);

	// 	// PS2data[1]=spi2_write_read_byte(0x42);
	// 	// delay_us(10);

	// 	// PS2data[2]=spi2_write_read_byte(0x00);
	// 	// delay_us(10);

	// 	// for(i = 3;i <9;i++)
	// 	// {
	// 	// 	PS2data[i]=spi2_write_read_byte(0x00);
	// 	// 	delay_us(10);
	// 	// }
			
	// 	// spi2_set_ss(1);
	//}
	// while (1) {
	// 	get_control();
		
	// 	// LCD_ShowIntNum(128,32,XY[0],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,48,XY[1],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,64,XY[2],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,80,XY[3],3,RED,WHITE,16);

	// 	for(i = 0;i <16;i++){
	// 	LCD_ShowIntNum(10,16+16*i,i,3,RED,WHITE,16);
	// 	}

	// 	for(i = 0;i <16;i++){
	// 	LCD_ShowIntNum(40,16+16*i,GAME_But[i],3,RED,WHITE,16);
	// 		if(GAME_But[i]>0)DISABLEPS2();
	// 	}
	// 	LCD_ShowIntNum(180,160,PS2STATE,3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,32,PS2data[0],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,48,PS2data[1],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,64,PS2data[2],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,80,PS2data[3],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,96,PS2data[4],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,112,PS2data[5],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,128,PS2data[6],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,144,PS2data[7],3,RED,WHITE,16);
	// 	// LCD_ShowIntNum(128,160,PS2data[8],3,RED,WHITE,16);
		
	// 	//delay_ms(500);

    // }


	return 0;
}

// void timer0_irq_handler()
// {
//     TIMER0_REG(TIMER0_CTRL) |= (1 << 2) | (1 << 0);  // clear int pending and start timer

//     count++;
// }

void timer0_irq_handler()
{
    //TIMER0_REG(TIMER0_CTRL) |= (1 << 2) ;  // clear int pending and start timer 
	// TIMER0_REG(TIMER0_CTRL) |= (1 << 2) | (1 << 0);  // clear int pending and start timer
    // PS2STATE=0;
	// t2++;
	// LCD_ShowIntNum(160,250,t2,3,RED,WHITE,12);
}