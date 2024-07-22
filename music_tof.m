function music_tof(csi_data, params)

% ---------------------------
% MUSIC解析tof，并绘制伪空间谱
% 输入：
%   - csi_data，n×90
%   - params
% 输出：
%   - 绘制伪空间谱
% ---------------------------

n = size(csi_data, 1);
csi = zeros(n, 3, 30); % n×3×30
csi(:, 1, :) = reshape(params.csi_data(:, 1:30), n, 1, 30);
csi(:, 2, :) = reshape(params.csi_data(:, 31:60), n, 1, 30);
csi(:, 3, :) = reshape(params.csi_data(:, 61:90), n, 1, 30);
csi = permute(csi, [2, 3, 1]); % 3×30×n
H = squeeze(csi(2, :, :));  % 取第2根天线，H为30×n
% H = awgn(H, snr, 'measured');  % 在信号中添加高斯噪声

% MUSIC算法解析tof
Cov = H * H' / params.N_samples;   % 协方差矩阵
[Ev, D] = eig(Cov);         % 特征值分解
% [V,D] = eig(A)返回特征值的对角矩阵D和矩阵V
% 其列是对应的右特征向量，使得AV = VD
EVA = diag(D)';             % 将特征值提取为1行
[~, index] = sort(EVA);     % 对特征值从小到大排序，index：1,2, ..., 10
EV = fliplr(Ev(:, index));  % 对应特征矢量排序
En = EV(:, params.N_source+1: params.N_Rx_subcarrier);  % 取特征向量矩阵的第N_source+1到N_Rx_antenna列特征向量组成噪声子空间
 
% 遍历所有路径长度，计算空间谱
path_length = zeros(1, 11);   % 预分配
p_music = zeros(1, 11); % 预分配
for i = 1:1001
    path_length(i) = i / 100; 
    a = exp(-1i * 2 * pi * params.subcarrier_30_freq * (path_length(i) / params.c)).';
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