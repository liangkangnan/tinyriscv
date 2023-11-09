#include "snake.h"
#include  "game.h"
#include  "../PS2/PS2.h"


#define  FOOD  "@"//我们把蛇身子和食物，以及地图用黑框框表示，定义为宏
//蛇初始位置的坐标
#define  INIT_X 30
#define  INIT_Y 30

void *
_sbrk (incr)
     int incr;
{
   extern char   end; /* Set by linker.  */
   static char * heap_end;
   char *        prev_heap_end;

   if (heap_end == 0)
     heap_end = & end;

   prev_heap_end = heap_end;
   heap_end += incr;

   return (void *) prev_heap_end;
}

#define  FOOD  "@"//我们把蛇身子和食物，以及地图用黑框框表示，定义为宏
//蛇初始位置的坐标



 

//画地图
void DrawMap(void){
	for(int i=0;i<GAMEPixel;i++)
	{
	LCD_DrawLine(GAMEMAP_X,GAMEMAP_Y+i,GAMEMAP_X+GAMEMAP_W+i,GAMEMAP_Y+i,GRAY);
	LCD_DrawLine(GAMEMAP_X-i,GAMEMAP_Y,GAMEMAP_X-i,GAMEMAP_Y+GAMEMAP_H+i,GRAY);
	LCD_DrawLine(GAMEMAP_X+GAMEMAP_W+i,GAMEMAP_Y,GAMEMAP_X+GAMEMAP_W+i,GAMEMAP_Y+GAMEMAP_H+i,GRAY);
	LCD_DrawLine(GAMEMAP_X,GAMEMAP_Y+GAMEMAP_H+i,GAMEMAP_X+GAMEMAP_W+i,GAMEMAP_Y+GAMEMAP_H+i,GRAY);
	}
} 

void InitSnake(pSnake ps){//因为蛇是一条链表，所以在开始的时候我们要初始化它
	pSnakeNode cur = NULL;//这是我们设置的蛇身子结点
	score=0; 
	cur = malloc(sizeof(SnakeNode));
	memset(cur,0x00,sizeof(SnakeNode));
	cur->next = NULL;
	cur->x = INIT_X;//设置蛇身子第一个人结点的位置
	cur->y = INIT_Y;
	for (int i=1;i<=4;i++)//这个循环使用头插的方法最后一次出循环的时候，cur就指向第一个结点，也就是蛇头结点
	{
		ps->_pSnake = malloc(sizeof(SnakeNode));
		ps->_pSnake->next = cur;
		ps->_pSnake->x =INIT_X+i*1;
		ps->_pSnake->y = INIT_Y;
		cur = ps->_pSnake;
	}
	// while (cur!=NULL)//按照每一个蛇身子结点里面的x,y坐标打印出整条蛇
	// {
	// 	for(int i=0;i<GAMEPixel;i++)
	// 	{
	// 		for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((cur->x)*GAMEPixel+i,(cur->y)*GAMEPixel+j,BLACK);
	// 	}

	// 	cur = cur->next;
	// }
	ps->_Dir = RIGHT;//设置初始蛇的朝向向右
	ps->_SleepTime = 500;
	ps->_Status = OK;//设置蛇的初始状态是OK，不然就没法玩了
}

void CreatFood(pSnake ps){//食物是蛇结构体的其中一种状态，我们把食物拿到单独函数中初始化
	pSnakeNode cur = NULL;
	pSnakeNode food = NULL;//食物也是一个结点，所以用蛇结点的结构体定义
	food = malloc(sizeof(SnakeNode));
again:
	memset(food,0x00,sizeof(SnakeNode));
	do{food->x = rand()%(GAMEMAP_W/GAMEPixel)+GAMEMAP_X/GAMEPixel;//因为我们横着的墙的最后一个设置在58的位置，一个食物的标致占两位，所以我们%56+2控制食物的x坐标不会越界
	}while(food->x>=(GAMEMAP_X/GAMEPixel+GAMEMAP_W/GAMEPixel) || food->x<=GAMEMAP_X/GAMEPixel);
	//food->y = rand()%25+1;//因为我们竖着的墙的最下的位置设置在26，所以%25+1
	food->y=INIT_Y;
	LCD_ShowIntNum(52,20,food->x,3,RED,WHITE,16);
	LCD_ShowIntNum(76,20,food->y,3,RED,WHITE,16);
	cur = ps->_pSnake;
	while (cur!=NULL)//这个循环判断随机产生的食物有没有和蛇的位置重叠，如果有重叠，那就使用goto语句返回，重新产生一个
	{
		if(cur->x == food->x && cur->y == food->y)
		{
			goto again;
		}
		cur = cur->next;
	}
	ps->_pFood = food;
	// for(int i=0;i<GAMEPixel;i++)
	// {
	// 	for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((food->x)*GAMEPixel+i,(food->y)*GAMEPixel+j,RED);
	// }
	score+=1;
	LCD_ShowIntNum(20,20,score,3,RED,WHITE,16);	
}

void EatFood(pSnakeNode nNode,pSnake ps){
	pSnakeNode cur = ps->_pSnake;//创建一个结点，当作食物，蛇吃掉之后把它当作结点插入到蛇身子里面
	nNode->next = cur;
	ps->_pSnake = nNode;
	cur = ps->_pSnake;
	while (cur!=NULL)//结点插入之后在把整个链表，也就是蛇打印一遍
	{
		//LCD_DrawPoint(cur->x,cur->y,BLACK);
		for(int i=0;i<GAMEPixel;i++)
		{
			for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((cur->x)*GAMEPixel+i,(cur->y)*GAMEPixel+j,BLACK);
		}
		cur = cur->next;
	}
	//LCD_ShowString(120,30,"creatfood start",BLACK,WHITE,16,0);
	CreatFood(ps);//食物吃掉之后，在产生一个新食物
	//LCD_ShowString(120,30,"creatfood   end",BLACK,WHITE,16,0);
}
void NoFood(pSnakeNode nNode,pSnake ps){//如果移动的下一步没有食物，那么就把蛇在新的位置打印一遍
	pSnakeNode cur = ps->_pSnake;
	nNode->next = cur;
	ps->_pSnake = nNode;
	cur = ps->_pSnake;
	for(int i=0;i<GAMEPixel;i++)
	{
		for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((ps->_pFood->x)*GAMEPixel+i,(ps->_pFood->y)*GAMEPixel+j,RED);
	}
	while (cur->next->next!=NULL)//因为蛇的长度是一定的，所以在新的位置打印之后，最后一个结点用空格代替，就产生了一条新蛇
	{
		//LCD_DrawPoint(cur->x,cur->y,BLACK);
		for(int i=0;i<GAMEPixel;i++)
		{
			for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((cur->x)*GAMEPixel+i,(cur->y)*GAMEPixel+j,BLACK);
		}
		cur = cur->next;
	}
	for(int i=0;i<GAMEPixel;i++)
	{
		for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((cur->x)*GAMEPixel+i,(cur->y)*GAMEPixel+j,BLACK);
	}
	for(int i=0;i<GAMEPixel;i++)
	{
		for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((cur->next->x)*GAMEPixel+i,(cur->next->y)*GAMEPixel+j,WHITE);
	}
	//LCD_ShowString((cur->next->x)*8,(cur->next->y)*16," ",BLACK,BLACK,16,0);
	free(cur->next);
	cur->next = NULL;
}

int NextHasFood(pSnakeNode nNode,pSnake ps){
	return ps->_pFood->x == nNode->x  && ps->_pFood->y == nNode->y;
}
void SnakeMove(pSnake ps){
	pSnakeNode  nNode = malloc(sizeof(SnakeNode));// 定义一个结点，赋给他蛇头结点的值，再根据下一步要走的方向，确定结点真正的值
	memset(nNode,0x00,sizeof(SnakeNode));
	nNode->x = ps->_pSnake->x;
	nNode->y = ps->_pSnake->y;
	switch (ps->_Dir)
	{
	case UP:
		nNode->y=(nNode->y-1-GAMEMAP_Y/GAMEPixel)%(GAMEMAP_H/GAMEPixel)+GAMEMAP_Y/GAMEPixel;
		break;
	case DOWN:
		nNode->y=(nNode->y+1-GAMEMAP_Y/GAMEPixel)%(GAMEMAP_H/GAMEPixel)+GAMEMAP_Y/GAMEPixel;
		break;
	case LEFT:
		nNode->x=(nNode->x-1-GAMEMAP_X/GAMEPixel)%(GAMEMAP_W/GAMEPixel)+GAMEMAP_X/GAMEPixel;
		break;
	case RIGHT:
		nNode->x=(nNode->x+1-GAMEMAP_X/GAMEPixel)%(GAMEMAP_W/GAMEPixel)+GAMEMAP_X/GAMEPixel;
		break;
	default:
		break;
	}
	if (NextHasFood(nNode,ps))//判断下一步有没有食物，
	{
		EatFood(nNode,ps);//有的话，就进入吃食物的操作函数
	} 
	else
	{
		//LCD_ShowString(120,30,"nofood         ",BLACK,WHITE,16,0);
		NoFood(nNode,ps);//没有的话，就进入没有食物的操作
	}
	
}
int KillBySelf(pSnake ps){//用遍历判断蛇头是否和蛇身子的结点的坐标重合，重合就是吃到了自己
	pSnakeNode cur= ps->_pSnake->next;
	while (cur!=NULL)
	{
		if (cur->x == ps->_pSnake->x  && cur->y == ps->_pSnake->y)
		{
			return 1;
		}
		cur = cur->next;
	}
	return 0;
}
int KillByWall(pSnake ps){//如果蛇头结点的坐标和墙重合了，那就是撞墙了
	if(ps->_pSnake->x == GAMEMAP_X/GAMEPixel  || ps->_pSnake->x == GAMEMAP_X/GAMEPixel+GAMEMAP_W/GAMEPixel || ps->_pSnake->y == GAMEMAP_Y/GAMEPixel || ps->_pSnake->y == GAMEMAP_Y/GAMEPixel+GAMEMAP_H/GAMEPixel)
		return 1;
	return 0;
}
int SnakeRun(pSnake ps){
	if (GAME_But[4] && GAME_But[5]);
	else if (GAME_But[6] && GAME_But[5]);
	else if (GAME_But[6] && GAME_But[7]);
	else if (GAME_But[4] && GAME_But[7]);
	else if(GAME_But[4] && ps->_Dir != DOWN){//判断键盘输入的如果是↑键，且蛇的方向没有向下，那就进入循环，把蛇的方向的状态改成向上
		DISABLEPS2();
		ps->_Dir = UP;
	}
	else if(GAME_But[6] && ps->_Dir != UP){//判断键盘输入的如果是↓键，且蛇的方向没有向上，那就进入循环，把蛇的方向的状态改成向下
		DISABLEPS2();
		ps->_Dir = DOWN;
	}
	else if(GAME_But[7] && ps->_Dir != RIGHT){//判断键盘输入的如果是左键，且蛇的方向没有向右，那就进入循环，把蛇的方向的状态改成向左
		DISABLEPS2();
		ps->_Dir = LEFT;
	}
	else if(GAME_But[5] && ps->_Dir != LEFT){//判断键盘输入的如果是右键，且蛇的方向没有向左，那就进入循环，把蛇的方向的状态改成向右
		DISABLEPS2();
		ps->_Dir = RIGHT;
	}
	if(GAME_But[13]){//如果键盘输入ESC键，那就状态改成退出
		DISABLEPS2();
		ps->_Status = ESC;
	}

	SnakeMove(ps);
	if (KillBySelf(ps))//判断当前是否会被自己咬死
	{
		ps->_Status = KILL_BY_SELF;
		LCD_ShowString(30,250,"selfdead",BLACK,WHITE,16,0);
	} 
	if(KillByWall(ps))//判断是否会被墙撞死
	{
		ps->_Status = KILL_BY_WALL;
		LCD_ShowString(30,250,"walldead",BLACK,WHITE,16,0);
	}
	if(ps->_Status == ESC){
		LCD_ShowString(30,250,"esc",BLACK,WHITE,16,0);
	}
	//delay_ms(20);
	LCD_ShowIntNum(180,20,ps->_Status,3,RED,WHITE,16);	
	if(ps->_Status == KILL_BY_WALL ||  ps->_Status == KILL_BY_SELF)return 1;
	else if(ps->_Status == ESC) return 2;
	else if(ps->_Status == OK)return 0;//如果蛇的状态是OK那就一直进入判断，
	else return 0;

}

void SnakeStart(pSnake ps){//开始之前的准备工作
	//DrawMap();//画地图
	score=0;
	InitSnake(ps);//初始化蛇。并画出
	CreatFood(ps);//创建一个食物
}
// // void Welcome(void){//欢迎界面
// // 	system("mode con cols=100 lines=30");
// // 	system("cls");
// // 	SetPos(38,6);
// // 	printf("welcome come to SnakeGame\n");
// // 	SetPos(38,8);
// // 	printf("↑↓←→control direction\n");
// // 	SetPos(45,10);
// // 	printf("ESC For Exit\n");
// // 	SetPos(42,12);
// // 	printf("宇哥科技倾情奉献\n");
// // 	getchar();
// // 	system("cls");
// // }

void SnakeClean(pSnake ps)
{
	score=0;
	delay_ms(2000);
	LCD_ShowString(30,250,"CLEAN   ",BLACK,WHITE,16,0);	
	
	// for(int i=0;i<GAMEPixel;i++)
	// {
	// 	for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((ps->_pSnake->x)*GAMEPixel+i,(ps->_pSnake->y)*GAMEPixel+j,WHITE);
	// }
	pSnakeNode cur= ps->_pSnake->next;
	pSnakeNode cur_next;
	while (cur!=NULL)
	{
		cur_next=cur;
		// for(int i=0;i<GAMEPixel;i++)
		// {
		// 	for(int j=0;j<GAMEPixel;j++)LCD_DrawPoint((cur->next->x)*GAMEPixel+i,(cur->next->y)*GAMEPixel+j,WHITE);
		// }
		cur = cur->next;
		free(cur_next);
	}
	//LCD_Fill(0, 0, 240, 280, WHITE);
	delay_ms(2000);	
	//DrawMap();
	InitSnake(ps);
	CreatFood(ps);
	LCD_ShowString(30,250,"INITFOOD ",BLACK,WHITE,16,0);	
}



