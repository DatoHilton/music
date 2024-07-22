clear;
close all;

%% 仿真设置
% 参数设置
N_Rx_subcarrier = 30;                % 接收天线子载波个数
N_signal_source = 1;                 % 信号源个数
simu_path_length = [5];              % 仿真路径长度（m）
snr = 10;                            % 信号信噪比（dB）
duration = 8;                        % 信号持续时间（秒）
sample_rate = 1000;                  % 采样率（Hz）
N_samples = duration * sample_rate;  % 总采样点个数
frequency = 5.32e9;                  % 信号中心频率（Hz）
delta_f = 312.5e3;                   % 相邻子载波频率间隔，单位：Hz，如何计算：20MHz/64
c = 229792458;                       % 光速（m/s）
subcarrier_num = [-28, -26, -24, -22, -20, -18, -16, ...
    -14, -12, -10, -8, -6, -4, -2, -1, 1, 3, 5, 7, 9, ...
    11, 13, 15, 17, 19, 21, 23, 25, 27, 28];  % 30个子载波的序列号
subcarrier_30_freq = zeros(1, 30);   % 30个子载波的频率分布数组
for i = 1:30
    num = subcarrier_num(i);
    freq = frequency + num * delta_f;
    subcarrier_30_freq(i) = freq;
end

% 仿真信号
A = exp(-1i * 2 * pi * subcarrier_30_freq .'* (simu_path_length / c));  % 仿真(接收天线个数×信号源个数)个信号
S = randn(N_signal_source, N_samples);  % 仿真(信号源个数×采样点个数)个信号的幅值
H = A * S;  % 仿真(接收天线个数×采样点个数)个信号
% H = awgn(H, snr, 'measured');  % 在信号中添加高斯噪声

%% MUSIC算法过程
Cov = H * H' / N_samples;   % 协方差矩阵
[Ev, D] = eig(Cov);         % 特征值分解
% [V,D] = eig(A)返回特征值的对角矩阵D和矩阵V
% 其列是对应的右特征向量，使得AV = VD
EVA = diag(D)';             % 将特征值提取为1行
[~, index] = sort(EVA);     % 对特征值从小到大排序，index：1,2, ..., 10
EV = fliplr(Ev(:, index));  % 对应特征矢量排序
En = EV(:, N_signal_source+1: N_Rx_subcarrier);  % 取特征向量矩阵的第N_signal_source+1到N_Rx_antenna列特征向量组成噪声子空间
 
% 遍历所有路径长度，计算空间谱
path_length = zeros(1, 11);   % 预分配
p_music = zeros(1, 11); % 预分配
for i = 1:1001
    path_length(i) = i / 100; 
    a = exp(-1i * 2 * pi * subcarrier_30_freq * (path_length(i) / c)).';
    p_music(i) = abs(1 / (a' * (En*En') * a));
end
% p_max = max(p_music);
% p_music = 10 * log10(p_music / p_max);  % 归一化处理

%% 绘图
figure();
plot(path_length, p_music, 'LineWidth', 3, 'Color', [0.1, 0.5, 0.8])
set(gca, 'FontWeight', 'bold', "FontSize", 14, 'LineWidth', 1.5);
set(gcf, 'color', 'white'); grid on; box on;
grid on;
xlabel('解析路径长度/m')
ylabel('伪空间谱')