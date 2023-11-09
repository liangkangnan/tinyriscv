#ifndef __PS2_H
#define __PS2_H

#include <stdint.h>
#include "../../include/spi.h"

#define PSS_Lx 2                //��ҡ��X������
#define PSS_Ly 3
#define PSS_Rx 0
#define PSS_Ry 1

/**********���а���״̬�ж�Ӧ��ֵ(���ALl_But)**********/
#define PSB_Left        0
#define PSB_Down        1
#define PSB_Right       2
#define PSB_Up          3
#define PSB_Start       4
#define PSB_Select      7
#define PSB_Square      8
#define PSB_Cross       9
#define PSB_Circle      10
#define PSB_Triangle    11
#define PSB_R1          12
#define PSB_L1          13
#define PSB_R2          14
#define PSB_L2          15

// uint8_t cmd[3] = {0x01,0x42,0x00};  // �����������
// uint8_t PS2data[9]= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};   //�洢�ֱ���������
// uint16_t XY[4] = {500,500,500,500};  //ҡ��ģ��ֵ
// uint8_t All_But[16] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}; 
// All_But[16] = {SELECT,1,2,START,LR_W,LR_R,LR_D,LR_L,L2,R2,L1,R1,RR_W,RR_R,RR_D,RR_L}

uint8_t cmd[3];
uint8_t PS2data[9];
uint16_t XY[4];
uint8_t All_But[16];

uint8_t PS2STATE;//0:enable 1:unable

void PS2_init(void);
void PS2_Get(void);  //��ȡԭʼ����
void delay_us(uint32_t udelay); //��������ӳ�
void GetData(void);  //�ܺ���
void GetXY(void); //��ԭʼ������xy������ת����0-1000
void CLear_Date(void);//�������
void All_Button(void);//��ÿһ������״̬����������ȫ����״̬�洢
void DISABLEPS2(void);

#endif