#include<stdio.h>
#include<windows.h>//调用windows的API函数
#include<conio.h>  //调用键盘处理函数
#include<time.h>   //调用随机函数
#define width 15   //地图宽度
#define hight 25   //地图高度

int key = 80;		//按键信息初始化
int Fivebox = 1;	//方块形状初始化

int map[width][hight] = { 0 };//用一个二维数组保存怎个游戏的方块信息
int (*p)(int, int, int);
int changebox(int x, int y, int choose,int (*p)(int,int,int));//方块能否变换由该函数决定
int movebox(int x, int y, int choose, int (*p)(int, int, int));//方块能否移动由该函数决定
void gotoxy(int x, int y)//坐标捕获函数
{
	COORD coord;
	coord.X = x;
	coord.Y = y;
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), coord);
}
/*
	*控制台按键所代表的数字
	*“↑”：72
	*“↓”：80
	*“←”：75
	*“→”：77
	*/
int appear_1()//检测是否出现一行都有方块的情况，这里采用暴力算法
{
	for (int y = 1, a=0; y < hight - 1; y++,a=0)
	{
		for (int x = 1; x < width - 1; x++)
		{
			if (map[x][y] == 1)
			{
				a++;
				if (a == width - 2)
				{
					return 1;
				}
			}
		}
	}
	return 0;
}
int all_0()//从下到上检测，获取第一个全没有方块的行数，算法同上
{
	for (int y = hight - 2,a=0; y > 0; y--,a=0)
	{
		for (int x = 1; x < width - 1; x++)
		{
			if (map[x][y] == 0)
			{
				a++;
				if (a == width - 2)
				{
					return y;
				}
			}
		}
	}
	return 0;
}
int all_1(int hig)//判断第hig行是否全都有方块，算法同上
{
	int a = 0;
	for (int x = 1; x < width - 1; x++)
	{
		if (map[x][hig] == 1)
		{
			a++;
			if (a == width - 2)
			{
				return 1;
			}
		}
	}
	return 0;
}
void drawmap_again()//游戏画面重绘，但不包括围墙
{
	Sleep(1000);
	int a0 = 0;			//用来记录“一行满块”的总行数
	int y = hight - 2;	//重绘的起始行数，也就是最底部
	int Y = all_0();	//作用参照all_0()
	while (y > Y)
	{
			if (all_1(y)) a0++;
			for (int w = 1; w < width - 1; w++)
			{
				if (y > Y - a0)
				{
					map[w][y] = map[w][y - a0];
					gotoxy(2 * w, y);
					(map[w][y] == 1) ? printf("■") : printf("  ");
				}
				else
				{
					map[w][y] = 0;
					gotoxy(2 * w, y);
					printf("  ");
				}	
			}
		y--;
	}
}

int keydown()
{
	if (_kbhit())			//判断是否由按键按下
	{
		fflush(stdin);		//把之前缓冲区的按键信息清除
		key = _getch();		
		key = _getch();		//这里获取两次，其原因可搜索_getch()的用法
	}
	switch (key)
	{
	case 72:return 1;
	case 75:return 2;
	case 77:return 3;
	}
	return 0;
}

void begin_drawmap()//游戏地图初始化绘制（其实就是画围墙）
{
	for (int _y = 0; _y < hight; _y++)
	{
		for (int x = 0; x < width; x++)
		{
			if (x == 0 || _y == 0 || _y == hight - 1 || x == width - 1)
				map[x][_y] = 1;
				gotoxy(2 * x, _y);
				(map[x][_y] == 1) ? printf("□") : printf("  ");
		}
	}
}
//L
void printbox1(int x, int y, int choose,int print)
{
	switch (choose)
	{
	case 1:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 2:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 3:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 4:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	}
}
int enable1(int x, int y, int choose)//判断对方块的操作是否可行，即方块的下一个位置或状态是否与其它方块重合
{
	switch (choose)
	{
	case 1:
		switch (key)
		{
		case 75:return (map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1 || map[(x - 2) / 2][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y - 1] == 1 || map[(x + 4) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return (map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1 || map[(x - 2) / 2][y - 1] == 1 || map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y - 1] == 1 || map[(x + 4) / 2][y + 1] == 1) ? 3 : 2;
		}
	case 2:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[(x - 4) / 2][y + 1] == 1) ? 0 : 1;
		case 77:return (map[x / 2][y + 1] == 1 || map[(x + 4) / 2][y] == 1) ? 0 : 1;
		case 72:return (map[(x - 4) / 2][y] == 1 || map[(x - 4) / 2][y + 1] == 1 || map[x / 2][y + 1] == 1 || map[(x + 4) / 2][y] == 1) ? 3 : 2;
		}
	case 3:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y - 1] == 1 || map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y - 1] == 1 || map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return (map[(x - 4) / 2][y - 1] == 1 || map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1 || map[(x + 2) / 2][y - 1] == 1 || map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y + 1] == 1) ? 3 : 2;
		}
	case 4:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[x / 2][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 4) / 2][y - 1] == 1 || map[(x + 4) / 2][y] == 1) ? 0 : 1;
		case 72:return (map[(x - 4) / 2][y] == 1 || map[x / 2][y - 1] == 1 || map[(x + 4) / 2][y - 1] == 1 || map[(x + 4) / 2][y] == 1) ? 3 : 2;
		}
	}
	return 0;
}
int upbox1(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
		if (map[x / 2][y + 2] == 1 || map[(x + 2) / 2][y + 2] == 1)
		{
			map[x / 2][y] = 1;
			map[x / 2][y - 1] = 1;
			map[x / 2][y + 1] = 1;
			map[(x + 2) / 2][y + 1] = 1;
			printbox1(x, y, choose,1);
			return 0;
		}
		break;
	case 2:
		if (map[(x - 2) / 2][y + 2] == 1 || map[x / 2][y + 1] == 1 || map[(x + 2) / 2][y + 1] == 1)
		{
			map[x / 2][y] = 1;
			map[(x - 2) / 2][y] = 1;
			map[(x + 2) / 2][y] = 1;
			map[(x - 2) / 2][y + 1] = 1;
			printbox1(x, y, choose,1);
			return 0;
		}
		break;
	case 3:
		if (map[(x - 2) / 2][y] == 1 || map[x / 2][y + 2] == 1)
		{
			map[x / 2][y] = 1;
			map[(x - 2) / 2][y - 1] = 1;
			map[x / 2][y - 1] = 1;
			map[x / 2][y + 1] = 1;
			printbox1(x, y, choose,1);
			return 0;
		}
		break;
	case 4:
		if (map[(x - 2) / 2][y] == 1 || map[x / 2][y + 1] == 1 || map[(x + 2) / 2][y] == 1)
		{
			map[x / 2][y] = 1;
			map[(x - 2) / 2][y] = 1;
			map[(x + 2) / 2][y] = 1;
			map[(x + 2) / 2][y - 1] = 1;
			printbox1(x, y, choose,1);
			return 0;
		}
		break;
	}
	return 1;
}
void Box1()
{
	int x = 10;//方块x坐标初始化
	int y = 2;
	int choose = 1;		//方块形态初始化为第一种
	int up = 1;
	while (upbox1(x, y, choose))//当方块不能落地时，退出对方块的操作
	{
		printbox1(x, y, choose,1);//第四个参数为1时表示画方块，为0时为删除方块
		Sleep(500);
		printbox1(x, y, choose,0);
		choose = changebox(x, y, choose,enable1);//每种方块有一个或多个形态，choose用来记录方块的形态
		x += movebox(x, y, choose,enable1);
		y += upbox1(x, y, choose);
	}
}
//土
void printbox2(int x, int y, int choose,int print)
{
	switch (choose)
	{
	case 1:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 2:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 3:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 4:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	}
}
int enable2(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[(x - 2) / 2][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 4) / 2][y] == 1 || map[(x + 2) / 2][y - 1] == 1) ? 0 : 1;
		case 72:return (map[x / 2][y + 1] == 1) ? 3 : 2;
			
		}
	case 2:
		switch (key)
		{
		case 75:return (map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1 || map[(x - 2) / 2][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y - 1] == 1 || map[(x + 4) / 2][y] == 1 || map[(x + 2) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return (map[(x - 2) / 2][y] == 1) ? 3 : 2;
		}
	case 3:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 4) / 2][y] == 1 || map[(x + 2) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return (map[x / 2][y - 1] == 1) ? 3 : 2;
	
		}
	case 4:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[(x - 2) / 2][y + 1] == 1 || map[(x - 2) / 2][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y - 1] == 1 || map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return (map[(x + 2) / 2][y] == 1) ? 3 : 2;
		}
	}
	return 0;
}
int upbox2(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
		if (map[(x - 2) / 2][y + 1] == 1 || map[x / 2][y + 1] == 1 || map[(x + 2) / 2][y + 1] == 1)
		{
			map[(x - 2) / 2][y] = 1;
			map[x / 2][y] = 1;
			map[(x + 2) / 2][y] = 1;
			map[x / 2][y - 1] = 1;
			printbox2(x, y, choose,1);

			return 0;
		}
		break;
	case 2:
		if (map[x / 2][y + 2] == 1 || map[(x + 2) / 2][y + 1] == 1)
		{
			map[x / 2][y - 1] = 1;
			map[(x + 2) / 2][y] = 1;
			map[x / 2][y] = 1;
			map[x / 2][y + 1] = 1;
			printbox2(x, y, choose,1);

			return 0;
		}

		break;
	case 3:
		if (map[(x - 2) / 2][y + 1] == 1 || map[x / 2][y + 2] == 1 || map[(x + 2) / 2][y + 1] == 1)
		{
			map[(x - 2) / 2][y] = 1;
			map[x / 2][y] = 1;
			map[(x + 2) / 2][y] = 1;
			map[x / 2][y + 1] = 1;
			printbox2(x, y, choose,1);

			return 0;
		}

		break;
	case 4:
		if (map[x / 2][y + 2] == 1 || map[(x - 2) / 2][y + 1] == 1)
		{
			map[x / 2][y - 1] = 1;
			map[(x - 2) / 2][y] = 1;
			map[x / 2][y] = 1;
			map[x / 2][y + 1] = 1;
			printbox2(x, y, choose,1);

			return 0;
		}

		break;
	}
	return 1;
}
void Box2()
{
	int x = 10;
	int y = 2;
	int choose = 1;
	int up = 1;
	while (upbox2(x, y, choose))
	{
		printbox2(x, y, choose,1);
		Sleep(500);
		printbox2(x, y, choose,0);
		choose = changebox(x, y, choose,enable2);
		x += movebox(x, y, choose,enable2);
		y += upbox2(x, y, choose);
	}
}
//I
void printbox3(int x, int y, int choose,int print)
{
	switch (choose)
	{
	case 1:
	case 3:
		gotoxy(x, y - 2);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 2:
	case 4:
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 4, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	}
}

int enable3(int x, int y, int choose)
{

	switch (choose)
	{
	case 1:
	case 3:
		switch (key)
		{
		case 75:return (map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y - 1] == 1 || map[(x - 2) / 2][y - 2] == 1 || map[(x - 2) / 2][y + 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y - 1] == 1 || map[(x + 2) / 2][y - 2] == 1 || map[(x + 2) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return (map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y - 2] == 1 || map[(x - 2) / 2][y + 1] == 1 || map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y - 2] == 1 || map[(x + 2) / 2][y + 1] == 1||map[(x+4)/2][y]==1) ? 3 : 2;
	
		}

	case 2:
	case 4:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1) ? 0 : 1;
		case 77:return (map[(x + 6) / 2][y] == 1) ? 0 : 1;
		case 72:return (map[x / 2][y + 1] == 1) ? 3 : 2;
			
		}
	}
	return 0;
}
int upbox3(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
	case 3:
		if (map[x / 2][y + 2] == 1)
		{
			map[x / 2][y - 2] = 1;
			map[x / 2][y - 1] = 1;
			map[x / 2][y] = 1;
			map[x / 2][y + 1] = 1;
			printbox3(x, y, choose,1);
			return 0;
		}
		break;
	case 2:
	case 4:
		if (map[(x - 2) / 2][y + 1] == 1 || map[x / 2][y + 1] == 1 || map[(x + 2) / 2][y + 1] == 1 || map[(x + 4) / 2][y + 1] == 1)
		{
			map[(x - 2) / 2][y] = 1;
			map[x / 2][y] = 1;
			map[(x + 2) / 2][y] = 1;
			map[(x + 4) / 2][y] = 1;
			printbox3(x, y, choose,1);
			return 0;
		}
		break;
	}
	return 1;
}
void Box3()
{
	int x = 10;
	int y = 3;
	int choose = 1;
	int up = 1;
	while (upbox3(x, y, choose))
	{
		printbox3(x, y, choose,1);
		Sleep(500);
		printbox3(x, y, choose, 0);
		choose = changebox(x, y, choose,enable3);
		x += movebox(x, y, choose,enable3);
		y += upbox3(x, y, choose);
	}
}
//z
void printbox4(int x, int y, int choose,int print)
{
	switch (choose)
	{
	case 1:
	case 3:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	case 2:
	case 4:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x - 2, y - 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
		break;
	}
}
int enable4(int x, int y, int choose)
{

	switch (choose)
	{
	case 1:
	case 3:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[(x - 2)][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y] == 1 || map[(x + 4) / 2][y - 1] == 1) ? 0 : 1;
		case 72:return (map[x / 2][y + 1] == 1 || map[(x - 2) / 2][y - 1] == 1) ? 3 : 2;
		}
	case 2:
	case 4:
		switch (key)
		{
		case 75:return (map[(x - 4) / 2][y] == 1 || map[(x - 4) / 2][y - 1] == 1 || map[(x - 2) / 2][y + 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 2) / 2][y] == 1 || map[(x + 2) / 2][y + 1] == 1 || map[x / 2][y - 1] == 1) ? 0 : 1;
		case 72:return (map[x / 2][y - 1] == 1 || map[(x + 2) / 2][y - 1] == 1) ? 3 : 2;

		}
	}
	return 0;
}
int upbox4(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
	case 3:
		if (map[x / 2][y + 1] || map[(x - 2) / 2][y + 1] == 1 || map[(x + 2) / 2][y] == 1)
		{
			map[x / 2][y] = 1;
			map[(x - 2) / 2][y] = 1;
			map[x / 2][y - 1] = 1;
			map[(x + 2) / 2][y - 1] = 1;
			printbox4(x, y, choose,1);
			return 0;
		}
		break;
	case 2:
	case 4:
		if (map[x / 2][y + 2] == 1 || map[(x - 2) / 2][y + 1] == 1)
		{
			map[x / 2][y] = 1;
			map[(x - 2) / 2][y] = 1;
			map[(x - 2) / 2][y - 1] = 1;
			map[x / 2][y + 1] = 1;
			printbox4(x, y, choose,1);

			return 0;
		}
		break;
	}
	return 1;
}
void Box4()
{
	int x = 10;
	int y = 2;
	int choose = 1;
	int up = 1;
	while (upbox4(x, y, choose))
	{
		printbox4(x, y, choose,1);
		Sleep(500);
		printbox4(x, y, choose,0);
		choose = changebox(x, y, choose,enable4);
		x += movebox(x, y, choose,enable4);
		y += upbox4(x, y, choose);
	}
}
//田
void printbox5(int x, int y, int choose,int print)
{
	switch (choose)
	{
	case 1:
	case 2:
	case 3:
	case 4:
		gotoxy(x, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(x + 2, y + 1);
		print == 1 ? printf("■") : printf("  ");
		gotoxy(25, 0);
	}
}
int enable5(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
	case 2:
	case 3:
	case 4:
		switch (key)
		{
		case 75:return (map[(x - 2) / 2][y] == 1 || map[(x - 2) / 2][y - 1] == 1) ? 0 : 1;
		case 77:return (map[(x + 4) / 2][y] == 1 || map[(x + 4) / 2][y + 1] == 1) ? 0 : 1;
		case 72:return 2;
		}
	}
	return 0;
}
int upbox5(int x, int y, int choose)
{
	switch (choose)
	{
	case 1:
	case 3:
	case 2:
	case 4:
		if (map[x / 2][y + 2] == 1 || map[(x + 2) / 2][y + 2] == 1)
		{
			map[x / 2][y] = 1;
			map[x / 2][y + 1] = 1;
			map[(x + 2) / 2][y] = 1;
			map[(x + 2) / 2][y + 1] = 1;
			printbox5(x, y, choose,1);
			return 0;
		}
		break;
	}
	return 1;
}
void Box5()
{
	int x = 10;
	int y = 2;
	int choose = 1;
	int up = 1;
	while (upbox5(x, y, choose))
	{
		printbox5(x, y, choose,1);
		Sleep(500);
		printbox5(x, y, choose, 0);
		choose = changebox(x, y, choose,enable5);
		x += movebox(x, y, choose,enable5);
		y += upbox5(x, y, choose);
	}
}
int creatnum()//随机生成哪种方块
{
	int hisfivebox;
	do
	{
		srand((unsigned int)time(NULL));
		hisfivebox = Fivebox;
		Fivebox = rand() % 5 + 1;
	} while (hisfivebox == Fivebox);
	return Fivebox;
}
int main()
{
	system("mode con cols=40 lines=25");//设置控制台的大小
	begin_drawmap();
	while (1)
	{
		int CHOOSE = creatnum();//本次游戏有五种方块形状
		switch (CHOOSE)
		{
		case 1:Box1();if (appear_1() == 1)drawmap_again();break;
		case 2:Box2();if (appear_1() == 1)drawmap_again();break;
		case 3:Box3();if (appear_1() == 1)drawmap_again();break;
		case 4:Box4();if (appear_1() == 1)drawmap_again();break;
		case 5:Box5();if (appear_1() == 1)drawmap_again();break;
		}
	}
	return 0;
}
int changebox(int x, int y, int choose,int (*p)(int,int,int))
{
	if (keydown() == 1 && p(x, y, choose) == 2)
	{
		key = 80;
		choose++;
		if (choose == 5)
			choose = 1;
		return choose;
	}
	return choose;
}
int movebox(int x, int y, int choose,int (*p)(int,int,int))
{

	if (keydown() == 2 && p(x, y, choose) == 1)//左
	{
		key = 80;
		return -2;
	}
	if (keydown() == 3 && p(x, y, choose) == 1)//右
	{
		key = 80;
		return 2;
	}
	return 0;
}