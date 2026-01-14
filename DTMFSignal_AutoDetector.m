%% ========================================================
%  数字信号处理课程设计 - 题目：电话拨号音自动检测
%  作者：jdfjdfxxx
%  功能：输入任意按键序列 → 自动合成标准DTMF信号 → 检测并输出按下的号码
%  支持按键：0-9, *, #, A, B, C, D
%  检测方法：Goertzel算法
%  ========================================================

clear; clc; close all;

%% 1. DTMF标准频率表（单位：Hz）
lowFreq  = [697, 770, 852, 941];           % 行频率（低频）
highFreq = [1209, 1336, 1477, 1633];       % 列频率（高频）

% 键盘映射
DTMF_table = [
    '1','2','3','A';
    '4','5','6','B';
    '7','8','9','C';
    '*','0','#','D'];

%% 2. 参数设置
fs = 8000;              % 采样率 8kHz
Tsymbol = 0.2;          % 按键持续 200ms
Tgap = 0.1;             % 静音 100ms
A = 0.3;                % 幅度

%% 3. 要检测的按键序列
keySequence = '520*#BCAD';      % 在此处更改起始输入值      
fprintf('正在合成按键序列：%s\n', keySequence);

%% 4. 生成 DTMF 信号
t_one = 0:1/fs:Tsymbol-1/fs;  
signal = [];

for k = 1:length(keySequence)
    key = keySequence(k);

    % 从表中找按键
    [r, c] = find(DTMF_table == key);
    if isempty(r)
        error('不支持的按键：%c', key);
    end
    
    f1 = lowFreq(r);    
    f2 = highFreq(c);   

    tone = A*(sin(2*pi*f1*t_one) + sin(2*pi*f2*t_one));
    signal = [signal, tone];

    if k < length(keySequence)
        signal = [signal, zeros(1, round(Tgap*fs))];
    end
end

% 播放
sound(signal, fs);
fprintf('播放完毕！\n');

%% 5. 绘制图像
figure('Color','white','Position',[100 100 1000 600]);

subplot(3,1,1);
t = (0:length(signal)-1)/fs;
plot(t, signal);
title('DTMF 时域波形'); xlabel('时间/s'); ylabel('幅度'); grid on;

subplot(3,1,2);
[Pxx,f] = pwelch(signal,[],[],[],fs);
plot(f,10*log10(Pxx));
title('DTMF 信号功率谱密度'); xlabel('频率/Hz'); ylabel('dB'); grid on;

subplot(3,1,3);
spectrogram(signal,256,250,256,fs,'yaxis');
title('DTMF 语谱图'); colorbar;

%% 6. Goertzel算法检测
freqs_to_detect = [lowFreq, highFreq];   
N = length(signal);
energy = zeros(1, length(freqs_to_detect));

for i = 1:length(freqs_to_detect)
    f = freqs_to_detect(i);
    k = round(0.5 + N*f/fs);
    w = 2*pi*k/N;
    coeff  = 2*cos(w);

    Q1 = 0; Q2 = 0;
    for n = 1:N
        Q0 = coeff*Q1 - Q2 + signal(n);
        Q2 = Q1;
        Q1 = Q0;
    end
    
    energy(i) = Q1*Q1 + Q2*Q2 - coeff*Q1*Q2;
end

energy = energy / max(energy);     

lowEnergy  = energy(1:4);
highEnergy = energy(5:8);

[~, lowIdx]  = max(lowEnergy);
[~, highIdx] = max(highEnergy);

detected_low  = lowFreq(lowIdx);
detected_high = highFreq(highIdx);

row = find(lowFreq == detected_low);
col = find(highFreq == detected_high);
detected_key = DTMF_table(row, col);

%% 7. 输出
fprintf('\n========== DTMF 检测结果 ==========\n');
fprintf('输入按键序列：%s\n', keySequence);
