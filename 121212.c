#include <reg52.h>

sbit Key1_P=P1^0;				
sbit Key2_P=P1^1;			
sbit Key3_P=P1^2;			
sbit Key4_P=P1^3;//定义四个p1口，后面用来检测按键高低电平				

sbit beep=P2^5;//蜂鸣器-->p2.5 	   

sbit k1=P1^4;
sbit k2=P1^6;
sbit k3=P1^7;//控制行线，扫描3x4矩阵按键

sbit LSA=P2^2;
sbit LSB=P2^3;
sbit LSC=P2^4;//控制数码管
unsigned char code duan[]={0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f};//段码0-9 
unsigned char dispcom[8];//缓冲区
unsigned char key;//存储当前检测到的按键编号
unsigned char key_flick;//按键防抖，连续按键计数
unsigned char xianshou=0,fen=0,temp_fen=0;//xainshou-->抢答选手号，把设置的时间赋给实际倒计时用的变量,temp_fen来储存，fen来显示

unsigned char time=0;//50ms溢出次数
unsigned int warn=0;//报警标志
unsigned char start=0;//开始标志
unsigned char end=0;//停止并复位

unsigned char jia=0;//起始抢答计时加
unsigned char jian=0;//起始抢答计时减


unsigned char situation=0;//===状态标志

unsigned int start_beep = 0; // 开始时蜂鸣器响标志（单位50ms，共10次）

void delay(unsigned int t)//==============================延时函数，单位毫秒ms
{
	unsigned int i,j;
	for(i=t;i>0;i--)
		for(j=110;j>0;j--);
}




void ChangeFor()//==========================================扫描显示数码管显示函数
{
	unsigned char i;
	dispcom[3]=duan[fen%10];
	dispcom[2]=duan[fen/10];
	dispcom[1]=0x40;
	dispcom[0]=duan[xianshou];	
	for(i=0;i<4;i++)
	{
		switch(i)//选择点亮哪个数码管
		{
			case(0):
				LSA=0;LSB=0;LSC=0;break;//显示第0位
			case(1):
				LSA=1;LSB=0;LSC=0;break;//显示第1位
			case(2):
				LSA=0;LSB=1;LSC=0;break;//显示第3位
			case(3):
				LSA=1;LSB=1;LSC=0;break;//显示第4位			
		}
		P0=dispcom[3-i];//发送数据
		delay(2); //间隔一段时间扫描	
		P0=0x00;//清除消影
	}		
}






void read_key()//=============================================扫描读键函数 
{
	k1=0;k2=1;k3=1;
	if(Key1_P==0)//选手1被按下
	{	
		key=1;		
	}
	if(Key2_P==0)//选手2被按下
	{
		key=2;		
	}
	if(Key3_P==0)//选手3被按下
	{
		key=3;	
	}
	if(Key4_P==0)//选手4被按下
	{
		key=4;	
	}
	k1=1;k2=0;k3=1;
	if(Key1_P==0)//选手5被按下
	{
	  key=5;
	}
	if(Key2_P==0)//选手6被按下
	{
		key=6;	
	}
	if(Key3_P==0)//选手7被按下
	{
		key=7;	
	}
	if(Key4_P==0)//选手8被按下
	{
		key=8;
	}	
	k1=1;k2=1;k3=0;
	if(Key1_P==0)//开始被按下
	{
		start=1;
		end=0;				
	}
	if(Key2_P==0)//复位被按下
	{
		start=0;
		end=1;
		situation=0;
	}	
	if(Key3_P==0)//起始时间增加按下
	{
		jia=1;	
	}
	if(Key4_P==0)//起始时间减少按下
	{
		jian=1;
	}		
}






void main()//==============================================主函数===================================================
{  
	TMOD=0X12;
	TH0=0x06;
	TL0=0x06;
	TH1=0x3c;//50ms计时初值
	TL1=0xff;
	EA=1;							
	ET0=1;						
	ET1=1;//初始化					 
	
	
	temp_fen=fen=30;//设置初始抢答倒计时为30s
	
	while(1)
	{
		ChangeFor();//扫描		
		read_key();//读键
	  if((start==1)&&(situation==0))//如果开始键按下，且处于空闲状态
{
    situation=1;// 状态1表示运行
    fen=temp_fen;
    TR1=1;// 启动定时器1（倒计时）
    start_beep=10;// 蜂鸣器响 0.5 秒（10次×50ms）
    TR0=1;//启动定时器0（控制蜂鸣器）
}
	   		
		if((jia==1)&&(situation==0))//如果时间增加键动作，且处于空闲状态
		{
			jia=0;	
			key_flick++;
			if((key_flick%25)==0)//消抖
				{
					key_flick=0;
					temp_fen++;//时间+1s
					fen=temp_fen;
				}
		}	
		
		if((jian==1)&&(situation==0))//如果时间减少键动作，且处于空闲状态
		{
			jian=0;
			key_flick++;
			if((key_flick%25)==0)//消抖
			{
				key_flick=0;
				temp_fen--;//时间-1s
				fen=temp_fen;
			}
		}			
		
		if((start==0)&&(situation==0))//如果按下开始键，且处于空闲状态
		{
			if((key!=0))//如果键值有效
			{
				xianshou=key;//显示抢答键（几号选手）
				situation=2;//状态2表示暂停
				TR1=0;//关闭T0 
				warn=8000;//报警值，蜂鸣器响2秒
				TR0=1;//启动T0 
			}
		}		
		while(situation==1)//如果运行标志有效，进入运行状态1
		{
		  ChangeFor();//显示
			read_key();//扫描抢答键
			if((key!=0))//如果键值有效
			{
				xianshou=key;//显示抢答键（几号选手）
				situation=2;
				TR1=0;//关闭T0 
				warn=8000;//报警值，蜂鸣器响2秒              
				TR0=0;//启动T0 
			}
		}
		
		if((end==1)&&(situation==2))//运行结束后复位键按下，且为状态2已停止
		{
		  situation=0;//回到初始空闲状态
			xianshou=0;
			temp_fen=fen=30;
			TR0=0;
			TR1=0;	
			start=0;
			key=0;
			end=0;
		}		
	}
}





void timer0(void) interrupt 1//定时器0中断函数
{
    if(start_beep>0)
		{
       start_beep--;
       beep=!beep;// 蜂鸣器响
       if(start_beep==0) 
			 {
           TR0=0;
           beep=1;//蜂鸣器关闭
       }
        return;
    }
    if(warn>0) 
		{
       warn--;
       beep=!beep;
       if(warn==0)
			{
          TR0=0;
          beep=1;
      }
    }
}






void timer1(void) interrupt 3		//============================定时器1中断服务程序
{
	TH1=0x3c;//50ms计时初值
	TL1=0xff;
	time++;//溢出次数加1
																				
	if(time==20)//时长达到1秒
	{
		time=0;
		if(fen>0)//倒计时大于0
		{
			fen--;//时间减1
		}
		else//如果倒计时归零的情况
		{
			TR1=0;
			warn=20000;//报警值
			situation=2;//停止状态2
			TR0=1;
		}	
	}
}