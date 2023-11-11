#include<iostream>
#include<conio.h>
#include<dos.h> 
#include <windows.h>
#include <time.h>

#define SCREEN_WIDTH 90
#define SCREEN_HEIGHT 26
#define WIN_WIDTH 70 

using namespace std; 

HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
COORD CursorPosition;

int enemyY[3];
int enemyX[3];
int enemyFlag[3];
char car[4][4] = { ' ','±','±',' ', 
                    '±','±','±','±', 
                    ' ','±','±',' ',
                    '±','±','±','±' }; 

int carPos = WIN_WIDTH/2;
int score = 0; 

void gotoxy(int x, int y){
    CursorPosition.X = x;
    CursorPosition.Y = y;
    SetConsoleCursorPosition(console, CursorPosition);
}
void setcursor(bool visible, DWORD size) {
    if(size == 0)
        size = 20;  

    CONSOLE_CURSOR_INFO lpCursor;   
    lpCursor.bVisible = visible;
    lpCursor.dwSize = size;
    SetConsoleCursorInfo(console,&lpCursor);
}
void drawBorder(){  
    for(int i=0; i<SCREEN_HEIGHT; i++){
        for(int j=0; j<17; j++){
            gotoxy(0+j,i); cout<<"±";
            gotoxy(WIN_WIDTH-j,i); cout<<"±";
        }
    } 
    for(int i=0; i<SCREEN_HEIGHT; i++){
        gotoxy(SCREEN_WIDTH,i); cout<<"±";
    } 
}
void genEnemy(int ind){
    enemyX[ind] = 17 + rand()%(33);  
}
void drawEnemy(int ind){
    if( enemyFlag[ind] == true ){
        gotoxy(enemyX[ind], enemyY[ind]);   cout<<"****";  
        gotoxy(enemyX[ind], enemyY[ind]+1); cout<<" ** "; 
        gotoxy(enemyX[ind], enemyY[ind]+2); cout<<"****"; 
        gotoxy(enemyX[ind], enemyY[ind]+3); cout<<" ** ";  
    } 
}
void eraseEnemy(int ind){
    if( enemyFlag[ind] == true ){
        gotoxy(enemyX[ind], enemyY[ind]); cout<<"    ";  
        gotoxy(enemyX[ind], enemyY[ind]+1); cout<<"    "; 
        gotoxy(enemyX[ind], enemyY[ind]+2); cout<<"    "; 
        gotoxy(enemyX[ind], enemyY[ind]+3); cout<<"    "; 
    } 
}
void resetEnemy(int ind){
    eraseEnemy(ind);
    enemyY[ind] = 1;
    genEnemy(ind);
}

void drawCar(){
    for(int i=0; i<4; i++){
        for(int j=0; j<4; j++){
            gotoxy(j+carPos, i+22); cout<<car[i][j];
        }
    }
}
void eraseCar(){
    for(int i=0; i<4; i++){
        for(int j=0; j<4; j++){
            gotoxy(j+carPos, i+22); cout<<" ";
        }
    }
}

int collision(){
    if( enemyY[0]+4 >= 23 ){
        if( enemyX[0] + 4 - carPos >= 0 && enemyX[0] + 4 - carPos < 9  ){
            return 1;
        }
    }
    return 0;
} 
void gameover(){
    system("cls");
    cout<<endl;
    cout<<"\t\t--------------------------"<<endl;
    cout<<"\t\t-------- Game Over -------"<<endl;
    cout<<"\t\t--------------------------"<<endl<<endl;
    cout<<"\t\tPress any key to go back to menu.";
    getch();
}
void updateScore(){
    gotoxy(WIN_WIDTH + 7, 5);cout<<"Score: "<<score<<endl;
}

void instructions(){

    system("cls");
    cout<<"Instructions";
    cout<<"\n----------------";
    cout<<"\n Avoid Cars by moving left or right. ";
    cout<<"\n\n Press 'a' to move left";
    cout<<"\n Press 'd' to move right";
    cout<<"\n Press 'escape' to exit";
    cout<<"\n\nPress any key to go back to menu";
    getch();
}

void play(){
    carPos = -1 + WIN_WIDTH/2;
    score = 0;
    enemyFlag[0] = 1;
    enemyFlag[1] = 0;
    enemyY[0] = enemyY[1] = 1;

    system("cls"); 
    drawBorder(); 
    updateScore();
    genEnemy(0);
    genEnemy(1);

    gotoxy(WIN_WIDTH + 7, 2);cout<<"Car Game";
    gotoxy(WIN_WIDTH + 6, 4);cout<<"----------";
    gotoxy(WIN_WIDTH + 6, 6);cout<<"----------";
    gotoxy(WIN_WIDTH + 7, 12);cout<<"Control ";
    gotoxy(WIN_WIDTH + 7, 13);cout<<"-------- ";
    gotoxy(WIN_WIDTH + 2, 14);cout<<" A Key - Left";
    gotoxy(WIN_WIDTH + 2, 15);cout<<" D Key - Right"; 

    gotoxy(18, 5);cout<<"Press any key to start";
    getch();
    gotoxy(18, 5);cout<<"                      ";

    while(1){
        if(kbhit()){
            char ch = getch();
            if( ch=='a' || ch=='A' ){
                if( carPos > 18 )
                    carPos -= 4;
            }
            if( ch=='d' || ch=='D' ){
                if( carPos < 50 )
                    carPos += 4;
            } 
            if(ch==27){
                break;
            }
        } 

        drawCar(); 
        drawEnemy(0); 
        drawEnemy(1); 
        if( collision() == 1  ){
            gameover();
            return;
        } 
        Sleep(50);
        eraseCar();
        eraseEnemy(0);
        eraseEnemy(1);   

        if( enemyY[0] == 10 )
            if( enemyFlag[1] == 0 )
                enemyFlag[1] = 1;

        if( enemyFlag[0] == 1 )
            enemyY[0] += 1;

        if( enemyFlag[1] == 1 )
            enemyY[1] += 1;

        if( enemyY[0] > SCREEN_HEIGHT-4 ){
            resetEnemy(0);
            score++;
            updateScore();
        }
        if( enemyY[1] > SCREEN_HEIGHT-4 ){
            resetEnemy(1);
            score++;
            updateScore();
        }
    }
}

int main()
{
    setcursor(0,0); 
    srand( (unsigned)time(NULL)); 

    do{
        system("cls");
        gotoxy(10,5); cout<<" -------------------------- "; 
        gotoxy(10,6); cout<<" |        Car Game        | "; 
        gotoxy(10,7); cout<<" --------------------------";
        gotoxy(10,9); cout<<"1. Start Game";
        gotoxy(10,10); cout<<"2. Instructions";  
        gotoxy(10,11); cout<<"3. Quit";
        gotoxy(10,13); cout<<"Select option: ";
        char op = getche();

        if( op=='1') play();
        else if( op=='2') instructions();
        else if( op=='3') exit(0);

    }while(1);

    return 0;
}


/*     光标通过gotoxy()函数被放置在屏幕上的指定位置。这表明getoxy()方法可以用来在屏幕上移动指针。它的主要目的是在指针放置的地方打印文本。
    COORD： 是一个用于保持屏幕的框架。X和Y是COORD坐标。一个标准设备的句柄由GetStdHandle函数返回（输入、输出、或错误）。一个句柄是通过系统表中的索引提供给Windows内核对象的一个访问点。我相信Std Output Handle()返回STD OUTPUT HANDLE值，以确定标准输出的活动控制台缓冲区。光标的位置是用SetControlCursorPosition（显然）设置的。
    标准输入（STDIN）、标准输出（STDOUT）和标准错误手柄（STDERR）都可以用GetStdHandle()方法检索。GetStdHandle()函数需要一个参数，即STD_INPUT_HANDLE、STD_OUTPUT_HANDLE或STD_ERROR_HANDLE。
    内置的 srand() 函数是C++ STL的一部分，它是cstdlib中指定的头文件。随机数生成器是用srand()函数初始化的。srand()函数建立了伪随机数流的初始值。如果没有调用srand()，rand()种子的设置就如同在程序启动时调用了srand(1)。如果种子被设置为其他值，生成器将从一个不同的起始点开始。
 */