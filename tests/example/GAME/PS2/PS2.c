#include "PS2.h"
#include "../../include/timer.h"


void PS2_init(void)
{

cmd[0] = 0x01;
cmd[1] = 0x42;
cmd[2] = 0x00;
XY[0] = 500;
XY[1] = 500;
XY[2] = 500;
XY[3] = 500;
TIMER0_REG(TIMER0_VALUE) = 10000000;  // 10ms period
spi2_init();
}

void DISABLEPS2()
{
	//PS2STATE=1;
	//TIMER0_REG(TIMER0_CTRL) = 0x07;     // enable interrupt and start timer
	delay_us(1000);
}



void delay_us(uint32_t udelay)    //����hal��us���ӳ�
{                         
	unsigned int a;
	while(udelay)
	{
		a=300;
		while(a--);
		udelay--;
	}
}


void PS2_Get(void)    //����ps2����
{
	short i = 0;

	spi2_set_ss(0);

	PS2data[0]=spi2_write_read_byte(0b10000000);
	delay_us(1);

	PS2data[1]=spi2_write_read_byte(0x42);
	delay_us(1);

	PS2data[2]=spi2_write_read_byte(0x00);
	delay_us(1);

	for(i = 3;i <9;i++)
	{
		PS2data[i]=spi2_write_read_byte(0x00);
		delay_us(1);
	}
		
	spi2_set_ss(1);
	
}


void changeDATA(uint8_t* data,int len)
{
	uint8_t* tdata;
	for(int j=0;j<len;j++)
	{
		tdata[j]=data[j];
		for(int i = 0 ; i<4 ; i++)
		{
		data[j] = data[j] | (tdata[j]&(0X80>>i))>>(7-i*2);
		data[j] = data[j] | (tdata[j]&(0X01<<i))<<(7-i*2);
		}
	}
}


void GetData(void)  //���ݴ���
{
	
	PS2_Get();   //��ȡԭʼ����
	//changeDATA(PS2data,9);
	//GetXY();   //��ҡ��ģ��ֵ�Ŵ�洢��������
	All_Button();
	CLear_Date();  //������ݣ��Ա��´�ʹ��
	if(PS2STATE)
	{
		for(int i=0;i<16;i++)
			All_But[i]=0;
	}
}

void GetXY(void)   //��ҡ��ģ��ֵ����0-1000�仯����������Ҳ��˷Ѿ���
{
	int i;
	for(i = 5;i < 9;i++)
	{
		PS2data[i] =(int) PS2data[i];		
		XY[i-5] = (PS2data[i]* 1000) / 255;   //���ֱ�ҡ�˵�ֵ�ֵ�0-1000֮�䣬���˷�ģ��ֵ����
		if(XY[i-5] <503 && XY[i-5] > 497)  XY[i-5] = 500;   //����
	}
	
}

void CLear_Date(void)
{
	int i;
	for(i = 0;i<9;i++)
	{
		if(i == 3 || i == 4) PS2data[i] = 0xff;
		else PS2data[i] = 0x00;  //�������
	}
	
}

void All_Button(void)  //��ÿһ��������ֵ��ʵ��ȫ�����޳�ͻ
{
	uint8_t loc = 1;
	uint8_t set = 0;
	uint8_t but = PS2data[3];

  for(loc = 8;loc > 0;loc--)  //λ�����ȡǰ��λ
  {
		loc -= 1;
		All_But[set] = (PS2data[3]&(1<<loc))>>loc;
		loc += 1;
		set++;
  }
	for(loc = 8;loc > 0;loc--)   //λ�����ȡ���λ
  {
		loc -= 1;
		All_But[set] = (PS2data[4]&(1<<loc))>>loc;
		loc += 1;
		set++;
  }
	for(set = 0;set < 16;set++)    //��ΪЭ���ϰ�������Ϊ0��δ����Ϊ1������Ҫ������з�ת
	{
		if(All_But[set] == 1)  All_But[set] = 0;
		else  All_But[set] = 1;			 
	}
	

}


