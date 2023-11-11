#include <stdlib.h>

#include "g2048.h"
#include "game.h"
// put any extra includes here, but don't delete the ones above
 
#define SIZE    4
#define BLOCKSIZE 40
#define GPASIZE 5
 
// add your function_prototypes here
 
// The functions moveLeft, moveRight, moveUp, moveDown
// return -1 if the specified moving of numbers  is not possible.
// Otherwise they move the numbers as indicated and return
// the change to the mscore from combining adjacent identical numbers.
// They return 0 if no numbers were combined.
 
/*
    题目的意思是这样的，需要‘严格’判断能否移动，我用flag标示移动的时候在第二个判断的时候出错了！
    拿下移为例，if(cell==0)的时候直接判断可以移动是错误的，当下移的时候，如果只有
    上面第一行的某一个元素为0，下面所有行不出现合并的情况下是不能下移的。
        所以在上下左右移动的过程中，当if(cell==0)即当前元素为0时要使得能够移动，就必须限制这个为0的
    元素不是上面第一行（下移时）、左侧第一列（右移）、右侧第一列（左移）、下面第一行（上移）、
        所以修改每个move函数中判断if(cell==0)代码的i或者j的循环条件，以避开判断时0所在的特殊行位置
        具体修改看下面部分注释（修改的只有每个move函数中第二个for循环中的i或者j的循环条件）
*/
 
int moveLeft(int board[SIZE][SIZE]) {
    int i,j,mscore=0,flag=-1;
    for(i=0;i<SIZE;i++)
    {
        for(j=0;j<SIZE;j++)
        {
            int cell=board[i][j];//cell单词用的不太恰当，表示当前元素，你可以采用更有意义的命名
            if(cell!=0)
            {
                int k=j+1;
                while(k<SIZE)
                {
                    int nextcell=board[i][k];
                    if(nextcell!=0)
                    {
                        if(cell==nextcell)
                        {
                            flag=0;//相邻两个元素相同，就说明能移动，所以改变flag的值
                            board[i][j]+=board[i][k];
                            mscore+=board[i][j];
                            board[i][k]=0;
                        }
                        k=SIZE;
                        break;
                    }
                    k++;
                }
            }
        }
    }
 
    //修改部分：for循环中的i或者j的循环条件
 
    for(i=0;i<SIZE;i++)
    {
        for(j=0;j<SIZE-1;j++)
        {
            int cell=board[i][j];
            if(cell==0)
            {
                int k=j+1;
                while(k<SIZE)
                {
                    int nextcell=board[i][k];
                    if(nextcell!=0)
                    {
                        flag=0;//
                        board[i][j]=nextcell;
                        board[i][k]=0;
                        k=SIZE;
                    }
                    k++;
                }
            }
        }
    }
    if(flag!=-1)
        return mscore;
    else
        return -1;
}
 
int moveRight(int board[SIZE][SIZE]) {
    int i,j,mscore=0,flag=-1;
    for(i=0;i<SIZE;i++)
    {
        for(j=SIZE-1;j>=0;j--)
        {
            int cell=board[i][j];
            if(cell!=0)
            {
                int k=j-1;
                while(k>=0)
                {
                    int nextcell=board[i][k];
                    if(nextcell!=0)
                    {
                        if(cell==nextcell)
                        {
                            flag=0;
                            board[i][j]+=board[i][k];
                            mscore+=board[i][j];
                            board[i][k]=0;
                        }
                        k=-1;
                        break;
                    }
                    k--;
                }
            }
        }
    }
 
     //修改部分：for循环中的i或者j的循环条件
 
    for(i=0;i<SIZE;i++)
    {
        for(j=SIZE-1;j>0;j--)
        {
            int cell=board[i][j];
            if(cell==0)
            {
 
                int k=j-1;
                while(k>=0)
                {
                    int nextcell=board[i][k];
                    if(nextcell!=0)
                    {
                        flag=0;//当前元素为0，说明能移动，改变flag的值
                        board[i][j]=nextcell;
                        board[i][k]=0;
                        k=-1;
                    }
                    k--;
                }
            }
        }
    }
    if(flag!=-1)
        return mscore;
    else
        return -1;
}
 
int moveDown(int board[SIZE][SIZE]) {
    int i,j,mscore=0,flag=-1;
    for(i=SIZE-1;i>=0;i--)
    {
        for(j=0;j<SIZE;j++)
        {
            int cell=board[i][j];
 
            if(cell!=0)
            {
                int k=i-1;
                while(k>=0)
                {
                    int nextcell=board[k][j];
                    if(nextcell!=0)
                    {
                        if(board[i][j]==board[k][j])
                        {
                            flag=0;
                            board[i][j]+=board[k][j];
                            mscore+=board[i][j];
                            board[k][j]=0;
                        }
                        k=0;
                        break;
                    }
                    k--;
                }
            }
        }
    }
 
     //修改部分：for循环中的i或者j的循环条件
    for(i=SIZE-1;i>0;i--)
    {
        for(j=0;j<SIZE;j++)
        {
            int cell=board[i][j];
            if(cell==0)
            {
                int k=i-1;
                while(k>=0)
                {
                    int nextcell=board[k][j];
                    if(nextcell!=0)
                    {
                        flag=0;
                        board[i][j]=nextcell;
                        board[k][j]=0;
                        k=0;
                    }
                    k--;
                }
            }
        }
    }
    if(flag!=-1)
        return mscore;
    else
        return -1;
}
 
int moveUp(int board[SIZE][SIZE]) {
   int i,j,mscore=0,flag=-1;
    for(i=0;i<SIZE;i++)
    {
        for(j=0;j<SIZE;j++)
        {
            int cell=board[i][j];
 
            if(cell!=0)
            {
                int k=i+1;
                while(k<SIZE)
                {
                    int nextcell=board[k][j];
                    if(nextcell!=0)
                    {
                        if(cell==nextcell)
                        {
                            flag=0;
                            board[i][j]+=board[k][j];
                            mscore+=board[i][j];
                            board[k][j]=0;
                        }
                        k=SIZE;
                        break;
                    }
                    k++;
                }
            }
        }
    }
 
     //修改部分：for循环中的i或者j的循环条件
    for(i=0;i<SIZE-1;i++)
    {
        for(j=0;j<SIZE;j++)
        {
            int cell=board[i][j];
            if(cell==0)
            {
 
                int k=i+1;
                while(k<SIZE)
                {
                    int nextcell=board[k][j];
                    if(nextcell!=0)
                    {
                        flag=0;
                        board[i][j]=nextcell;
                        board[k][j]=0;
                        k=SIZE;
                    }
                    k++;
                }
            }
        }
    }
    if(flag!=-1)
        return mscore;
    else
        return -1;
}
 
// gameOver returns 0 iff it is possible to make a move on the board
// It returns 1 otherwise.
 
int gameOver(int board[SIZE][SIZE]) {
    int copy_board[SIZE][SIZE],i,j;
    /*为了避免直接把board[][]传进move函数判断的时候改变board，所以把board复制给
    另一个数组,然后判断，这样就不会改变board数组了
    */
    for(i=0;i<SIZE;i++)
    {
        for(j=0;j<SIZE;j++)
        {
            copy_board[i][j]=board[i][j];
        }
    }
    if(moveDown(copy_board)==-1&&moveUp(copy_board)==-1&&moveLeft(copy_board)==-1&&moveRight(copy_board)==-1)//如果四个移动函数都返回-1即不能移动GameOver
        return 1;
    else
        return 0;
 
}
 
// boardContains2048 returns 1 iff the board contains 2048.
// It returns 0 otherwise.
 
int boardContains2048(int board[SIZE][SIZE]) {
    int i,j;
    for(i=0;i<SIZE;i++)
    {
        for(j=0;j<SIZE;j++)
        {
            if(board[i][j]==2048)
                return 1;
        }
    }
    return 0;
}
 
//
// add your functions here
//
 
//
// You do not need to modify the code below here.
//
// If you wish to modify the code below, you have
// misunderstood the assignment specification
//

void insertNewNumber(int board[SIZE][SIZE]);

// add a new number to the board
// it will either be a 2 (90% probability) or a 4 (10% probability)
// do not change this function
 
void insertNewNumber(int board[SIZE][SIZE]) {
    int row, column;
    int index, availableSquares = 0;
 
    // count vacant squares
    for (row = 0; row < SIZE; row = row + 1) {
        for (column = 0; column < SIZE; column = column + 1) {
            if (board[row][column] == 0) {
                availableSquares = availableSquares + 1;
            }
        }
    }
 
    if (availableSquares == 0) {     
        return;
    }
 
    // randomly pick a vacant square
    index = rand() % availableSquares;
    for (row = 0; row < SIZE; row = row + 1) {
        for (column = 0; column < SIZE; column = column + 1) {
            if (board[row][column] == 0) {
                if (index == 0) {
                    if (rand() % 10 == 0) {
                        board[row][column] = 4;
                    } else {
                        board[row][column] = 2;
                    }
                    return;
                }
                index = index - 1;
            }
        }
    }
}

void g2048_init(pG2048 p2048)
{
    for(int i=0;i<4;i++)for(int j=0;j<4;j++)p2048->_G2048Data[i][j]=0;
    p2048->_G2048Status=G2048Normal;
    p2048->_G2048Scoe=0;
    insertNewNumber(p2048->_G2048Data);
    insertNewNumber(p2048->_G2048Data);
}

void g2048_show(pG2048 p2048)
{
    for(int i=0;i<4;i++){
        for(int j=0;j<4;j++){
            if(p2048->_G2048Data[i][j]==0)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,BLUE,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==2)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,BRED,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==4)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,DARKBLUE,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==8)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,GBLUE,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==16)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,RED,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==32)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,MAGENTA,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==64)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,GREEN,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==128)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,CYAN,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==256)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,YELLOW,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==512)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,BROWN,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==1024)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,BRRED,WHITE,24);
            else if	(p2048->_G2048Data[i][j]==2048)
            LCD_ShowIntNum(24+j*48,44+i*48,p2048->_G2048Data[i][j],4,GRAY,WHITE,24);
        }
    }
}

int g2048_run(pG2048 p2048)
{
 
    //g2048_show(p2048);

    int movescore=0;
    int flag=0;
    if (GAME_But[4] && GAME_But[5]);
    else if (GAME_But[6] && GAME_But[5]);
    else if (GAME_But[6] && GAME_But[7]);
    else if (GAME_But[4] && GAME_But[7]);
    else if (GAME_But[7]) {
        movescore = moveLeft(p2048->_G2048Data);
        flag=1;
    } else if (GAME_But[6]) {
        movescore = moveDown(p2048->_G2048Data);
        flag=1;
    } else if (GAME_But[4]) {
        movescore = moveUp(p2048->_G2048Data);
        flag=1;
    } else if (GAME_But[5]) {
        movescore = moveRight(p2048->_G2048Data);
        flag=1;
    }
    LCD_ShowIntNum(180,20,movescore,1,RED,WHITE,12);
    if (movescore == -1) {   
    } 
    else if(flag==1){
        flag=0;
        insertNewNumber(p2048->_G2048Data);
        p2048->_G2048Scoe = p2048->_G2048Scoe + movescore;
        g2048_show(p2048);
        delay_ms(200);
    }

    if(GAME_But[13]){
        p2048->_G2048Status=G2048ESC;
        LCD_ShowString(30,250,"GAMEESC  ",BLACK,WHITE,16,0);
        delay_ms(2000);
        return 2;
    }else if(gameOver(p2048->_G2048Data)){
        p2048->_G2048Status=G2048DEAD;
        LCD_ShowString(30,250,"GAMEOVER ",BLACK,WHITE,16,0);
        delay_ms(2000);return 1;
    }else if(boardContains2048(p2048->_G2048Data)){
        p2048->_G2048Status=G2048Win;
        LCD_ShowString(30,250,"GAMEWON  ",BLACK,WHITE,16,0);
        delay_ms(2000);return 1;
    }
    else return 0;
}


