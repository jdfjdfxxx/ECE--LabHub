N=16;N1=8;
n=0:N-1;k=0:N1-1;
x1n=exp(j*pi*n/8);             %产生x1(n)
X1k=fft(x1n,N);                %计算N点DFT[x1(n)]
X2k=fft(x1n,N1);               %计算N1点DFT[x1(n)]
x2n=cos(pi*n/8);               %产生x2(n)
X3k=fft(x2n,N);                %计算N点DFT[x2(n)]
X4k=fft(x2n,N1);               %计算N1点DFT[x2(n)]
subplot(2,2,1);stem(n,abs(X1k),'.');axis([0,20,0,20]);ylabel('|X1(k)|')
title('16点的DFT[x1(n)]')
subplot(2,2,2);stem(n,abs(X3k),'.');axis([0,20,0,20]);ylabel('|X2(k)|')
title('16点的DFT[x2(n)]')
subplot(2,2,3);stem(k,abs(X2k),'.');axis([0,20,0,20]);ylabel('|X1(k)|')
title('8点的DFT[x1(n)]')
subplot(2,2,4);stem(k,abs(X4k),'.');axis([0,20,0,20]);ylabel('|X2(k)|')
title('8点的DFT[x2(n)]')




---------------------------------------

clear
xn=[1,2,-1,3];
X=fft(xn)
x=ifft(X)

-------------------------------------------



% 产生两个正弦加白噪声；
 N=256;
 f1=.1;f2=.2;fs=1;
 a1=5;a2=3;
 w=2*pi/fs;
 x=a1*sin(w*f1*(0:N-1))+a2*sin(w*f2*(0:N-1))+randn(1,N);
 % 应用FFT 求频谱； 
 subplot(2,2,1);
 plot(x(1:N/4));
 title('原始信号');
 f=-0.5:1/N:0.5-1/N;
 X=fft(x); 
 y=ifft(X);
 subplot(2,2,2);
 plot(f,fftshift(abs(X)));
 title('频域信号');
 subplot(2,2,3);
 plot(real(x(1:N/4)));                              
 title('时域信号'); 


 ---------------------------------------

 t=0:0.001:1;      %采样周期为0.001s，即采样频率为1000Hz;        x=sin(2*pi*100*t)+sin(2*pi*200*t)+rand(size(t));
                       %产生受噪声污染的正弦波信号；
subplot(2,1,1)
plot(x(1:50));         %画出时域内的信号；
Y=fft(x,512);          %对x进行512点的傅里叶；
f=1000*(0:256)/512;    %设置频率轴（横轴）坐标，1000为采样频率；
subplot(2,1,2)
plot(f,Y(1:257));      %画出频域内的信号；



----------------------=================================----------------




clear all;
fp=100;fs=300;Fs=1000;
rp=3;rs=20;
%
wp=2*pi*fp/Fs;
ws=2*pi*fs/Fs;
Fs=Fs/Fs;        %let Fs=1
% Firstly to finish frequency prewarping;
wap=tan(wp/2);was=tan(ws/2);
[n,wn]=buttord(wap,was,rp,rs,'s')
% Note:'s'!
[z,p,k]=buttap(n);
[bp,ap]=zp2tf(z,p,k)
[bs,as]=lp2lp(bp,ap,wap)
% Note:s=(2/Ts)(z-1)/(z+1);Ts=2,that is 2fs=1,fs=0.5;
[bz,az]=bilinear(bs,as,Fs/2)
[h,w]=freqz(bz,az,256,Fs*1000);
plot(w,abs(h));grid on;


-------------------------------

clear all;
N=10;
b1=fir1(N,0.25,boxcar(N+1));    % 用矩形窗作为冲激响应的窗函数
b2=fir1(N,0.25,hamming(N+1));   % 用Hamming窗作为冲激响应的窗函数
%
M=128;
h1=freqz(b1,1,M);
h2=freqz(b2,1,M);
% 分别求两个滤波器的频率响应；
t=0:10;
subplot(221)
stem(t,b2,'.');hold on;
plot(t,zeros(1,11));grid;
f=0:0.5/M:0.5-0.5/M;
M1=M/4;
for k=1:M1
   hd(k)=1;
   hd(k+M1)=0;
   hd(k+2*M1)=0;
   hd(k+3*M1)=0;
end
subplot(222)
plot(f,abs(h1),'b-',f,abs(h2),'g-',f,hd,'-');grid; 



