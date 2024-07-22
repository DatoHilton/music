clear;
close all;

%% 仿真设置
% 参数设置
ang2rad = pi / 180;                  % 角度转弧度系数
N_Rx_antenna = 5;                    % 接收天线个数
N_signal_source = 2;                 % 信号源个数
simu_AoA = [20, 50];                % 仿真AoA（°）
snr = 10;                            % 信号信噪比（dB）
duration = 8;                        % 信号持续时间（秒）
sample_rate = 1000;                  % 采样率（Hz）
N_samples = duration * sample_rate;  % 总采样点个数
antenna_dis = 0.025;                 % 天线间距（m）
frequency = 5.32e9;                  % 信号中心频率（Hz）
c = 229792458;                       % 光速（m/s）

% 仿真信号
pos_antenna = 0:antenna_dis:(N_Rx_antenna-1) * antenna_dis;  % N个天线的位置
A = exp(-1i * 2 * pi * (frequency/c) * pos_antenna .'* sin(simu_AoA * ang2rad));  % 仿真(接收天线个数×信号源个数)个信号
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
En = EV(:, N_signal_source+1: N_Rx_antenna);  % 取特征向量矩阵的第N_signal_source+1到N_Rx_antenna列特征向量组成噪声子空间
 
% 遍历所有角度，计算空间谱
angle = zeros(1, 361);   % 预分配
p_music = zeros(1, 361); % 预分配
for i = 1:361
    angle(i) = (i - 181) / 2;      % 映射到-90度到90度
    theta_m = angle(i) * ang2rad;  % 转为弧度
    a = exp(-1i * 2 * pi * (frequency/c) * pos_antenna * sin(theta_m)).';
    p_music(i) = abs(1 / (a' * (En*En') * a));
end
% p_max = max(p_music);
% p_music = 10 * log10(p_music / p_max);  % 归一化处理

%% 绘图
figure();
plot(angle, p_music, 'LineWidth', 3, 'Color', [0.1, 0.5, 0.8])
set(gca, 'FontWeight', 'bold', "FontSize", 14, 'LineWidth', 1.5);
set(gcf, 'color', 'white'); grid on; box on;
grid on;
xlabel('解析AoA/度')
ylabel('伪空间谱')