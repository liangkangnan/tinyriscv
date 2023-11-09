#ifndef __LCD_INIT_H
#define __LCD_INIT_H

#include <stdint.h>
#include "../../include/gpio.h"
#define USE_HORIZONTAL 0  //?????????? 0?1??? 2?3???


#if USE_HORIZONTAL==0||USE_HORIZONTAL==1
#define LCD_W 240
#define LCD_H 280

#else
#define LCD_W 280
#define LCD_H 240
#endif

#define u8  unsigned char
#define u16 unsigned int



//-----------------LCD�˿ڶ���----------------

#define LCD_SCLK_Clr() GPIO_REG(GPIO_DATA) &= ~0B00000100;  // GPIO2输出低
#define LCD_SCLK_Set() GPIO_REG(GPIO_DATA) |= 0B00000100;  // GPIO2输出高

#define LCD_MOSI_Clr() GPIO_REG(GPIO_DATA) &= ~0B00001000;  // GPIO3输出低
#define LCD_MOSI_Set() GPIO_REG(GPIO_DATA) |= 0B00001000;  // GPIO3输出高

#define LCD_RES_Clr() GPIO_REG(GPIO_DATA) &= ~0B00010000;  // GPIO4输出低
#define LCD_RES_Set() GPIO_REG(GPIO_DATA) |= 0B00010000;  // GPIO4输出高

#define LCD_DC_Clr() GPIO_REG(GPIO_DATA) &= ~0B00100000;  // GPIO5输出低
#define LCD_DC_Set() GPIO_REG(GPIO_DATA) |= 0B00100000;  // GPIO5输出高

#define LCD_CS_Clr()  GPIO_REG(GPIO_DATA) &= ~0B01000000;  // GPIO6输出低
#define LCD_CS_Set()  GPIO_REG(GPIO_DATA) |= 0B01000000;  // GPIO6输出高

#define LCD_BLK_Clr()  GPIO_REG(GPIO_DATA) &= ~0B10000000;  // GPIO7输出低
#define LCD_BLK_Set()  GPIO_REG(GPIO_DATA) |= 0B10000000;  // GPIO7输出高



void delay_ms(unsigned int ms);//��׼ȷ��ʱ����
void LCD_GPIO_Init(void);//��ʼ��GPIO
void LCD_Writ_Bus(u8 dat);//ģ��SPIʱ��
void LCD_WR_DATA8(u8 dat);//д��һ���ֽ�
void LCD_WR_DATA(u16 dat);//д�������ֽ�
void LCD_WR_REG(u8 dat);//д��һ��ָ��
void LCD_Address_Set(u16 x1,u16 y1,u16 x2,u16 y2);//�������꺯��
void LCD_Init(void);//LCD��ʼ��
#endif




