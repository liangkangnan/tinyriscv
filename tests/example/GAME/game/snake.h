#ifndef __SNAKE_H
#define __SNAKE_H

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "../LCD/lcd.h"
#include "../LCD/lcd_init.h"



// 蛇身子节点，因为我们要打印蛇身子的每一个节点在地图上显示，所以结构体里面要有蛇身子结点的x,y坐标，
 typedef struct node{
 	int x;
	int y;
	struct node* next;//因为使用链表的结构，所以我们要储存每一个结点下一个结点的地址，构成一条链表
}SnakeNode,*pSnakeNode;
// 蛇的行走方向
enum DIRECTION{ UP=1,DOWN,LEFT,RIGHT};
//蛇的状态
enum  Status{OK,KILL_BY_SELF,KILL_BY_WALL,ESC};
// 蛇本身
typedef struct snake{
	pSnakeNode _pSnake;//蛇头指针
	pSnakeNode _pFood;//食物
	enum DIRECTION _Dir;//蛇行走的方向
	enum Status _Status;//蛇的当前状态
	int _SleepTime;//每走一步停留的时间
}Snake,*pSnake;

uint16_t score;

void DrawMap(void);
int SnakeRun(pSnake ps);
void SnakeStart(pSnake ps);
void SnakeClean(pSnake ps);
void GameShow(pSnake ps);

#endif
