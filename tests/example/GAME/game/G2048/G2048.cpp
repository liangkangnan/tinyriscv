#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <windows.h>

#define ROW 4
#define COL ROW

#define KEY1           224
#define KEY_LEFT    75
#define KEY_UP       72
#define KEY_RIGHT 77
#define KEY_DOWN 80

int g_sgap = 0;

/*
应用市场下载2048
如果需要图形界面,需要加界面库
*/

//在数组arr产生一个新的数字
void GetNewVal(int arr[ROW][COL])
{
 srand( (unsigned)time( NULL ) + g_sgap++);
 int x = rand()%ROW;//行下标,保证不越界
 int y = rand()%COL;//列下标,保证不越界

 int newval = 2;
 if(x == 0)//75%的概率为2,25%的概率为4
 {
  newval = 4;
 }

 //找到空闲的格子
 while(arr[x][y] != 0)//该格子已经有值,todo有可能死循环
 {
  y++;
  if(y == COL)//
  {
   y = 0;
   x = (x+1)%ROW;//下一行
  }
 }

 arr[x][y] = newval;
}

//打印
void Show(int arr[ROW][COL])
{
 system("cls");
 for(int i=0; i<ROW;i++)
 {
  for(int j=0;j<COL;j++)
  {
   printf("%4d",arr[i][j]);
  }
  printf("\n");
 }
}

//显示开始界面
void Start(int arr[ROW][COL])
{
 //获取两个数字,然后显示界面
 GetNewVal(arr);
 GetNewVal(arr);

 Show(arr);
}

//获取键值,左:1,上:2,右:3,下:4,其它:0
int GetButton()
{
 int key1 = 0;//第一个键值
 int key2 = 0;//第二个键值
 while(1)
 {
  if(_kbhit())
  {
   key1 = _getch();//获得第一个键值
   if(key1 == KEY1)//0xE0
   {
    key2 = _getch();//获取第二个键值
    if(key2 == KEY_LEFT)
    {
     return 1;
    }
    else if(key2 == KEY_UP)
    {
     return 2;
    }
    else if(key2 == KEY_RIGHT)
    {
     return 3;
    }
    else if(key2 == KEY_DOWN)
    {
     return 4;
    }
   }
  }
  Sleep(100);//睡眠,让出CPU,避免忙等待
 }
}

//向左合并
bool MergeLeft(int arr[ROW][COL])
{
 int x1 = -1;//第一个需要合并的数字下标
 
 bool flg = false;//当前没有有效合并(没有数据合并,也没有数据移动)

 for(int i=0;i<ROW;i++)
 {
  x1 = -1;
  //第一步,合并相同的数字
  for(int j=0;j<COL;j++)
  {
   if(arr[i][j]!=0)
   {
    if(x1 == -1)//该行第一个非0的值
    {
     x1 = j;
    }
    else//当前第二个需要处理的值
    {
     if(arr[i][j] == arr[i][x1])//合并,将x1下标的值*2,j下标的值置为0
     {
      arr[i][x1] *= 2;
      arr[i][j] = 0;
      x1 = -1;
      flg = true;
     }
     else//第一个值和第二个值不等,
     {
      x1 = j;
     }
    }
   }

  }

  //第二步,移动数字
  int index = 0;//当前可以放数据的下标
  for(int j=0;j<COL;j++)
  {
   if(arr[i][j]!=0)//需要移动数据
   {
    if(index != j)
    {
     arr[i][index] = arr[i][j];
     arr[i][j] = 0;
     index++;
     flg = true;
    }
    else
    {
     index++;
    }
   }
  }
 }
 return flg;
}

//游戏是否结束
//1.没有空闲单元格
//2.相邻没有相同的数字
bool IsGameOver(int arr[ROW][COL])
{
 //判断有没有空闲单元格
 int activeCell = 0;//统计空闲单元格数量
 for(int i=0;i<ROW;i++)
 {
  for(int j=0;j<COL;j++)
  {
   if(arr[i][j] == 0)
   {
    activeCell++;
   }
  }
 }
 if(activeCell != 0)
 {
  return false;
 }

 //相邻是否有相同的数字,只需要判断右边和下边
 for(int i=0;i<ROW;i++)
 {
  for(int j=0;j<COL;j++)
  {
   //if(arr[i][j]==arr[i][j+1] || arr[i][j] == arr[i+1][j])
   if(j+1<COL&&arr[i][j]==arr[i][j+1] || i+1<ROW&&arr[i][j]==arr[i+1][j])
   {
    return false;
   }
  }
 }
 return true;
}

void Run(int arr[ROW][COL])
{
 int bt;
 bool rt = false;
 while(1)
 {
  bt = GetButton();

  if(bt == 1)//方向键左
  {
   rt = MergeLeft(arr);
   if(rt)
   {
    GetNewVal(arr);
    Show(arr);
    if(IsGameOver(arr))
    {
     return ;
    }
   }
  }
 }

}

int main()
{
 int arr[ROW][COL] = {0};

 Start(arr);

 Run(arr);

 return 0;
}


int main1()
{
 int a = 0;
 while(1)
 {
  if(_kbhit())
  {
   a = _getch();//getchar();
   printf("键值是:%d\n",a);
  }
 }
 return 0;
}


/*
int main()
{
 srand( (unsigned)time( NULL ) );


 for(int i=0;i<10;i++)
 {
  printf("%d ",rand());
 }
 printf("\n");

 return 0;
}
*/