function params = parameters()

% ----------------------------------------------
% 生成仿真信号，返回n×90的csi_data
% 输入：
%   - 无
% 输出：
%   - csi_data，n×90
% 注意：如果使用真实数据，参数也要相应修改为真实数据
% ----------------------------------------------

%% 仿真参数设置
params.N_Rx_antenna = 3;                      % 接收天线个数
params.N_Rx_subcarrier = 30;                  % 接收天线子载波个数
antenna_dis = 0.025;                          % 天线间距（m）
params.frequency = 5.32e9;                    % 信号中心频率（Hz）
delta_f = 312.5e3;                            % 相邻子载波频率间隔（Hz），如何计算：20MHz/64
params.N_source = 2;                          % 信号源个数，也就是期待解析出峰的个数
simu_AoA = [20,50];                           % 仿真AoA（°）
simu_path_length = [5,7];                     % 仿真路径长度（m）
snr = 10;                                     % 信号信噪比（dB）
duration = 8;                                 % 信号持续时间（秒）
sample_rate = 1000;                           % 采样率（Hz）
params.N_samples = duration * sample_rate;    % 总采样点个数
params.c = 229792458;                         % 光速（m/s）
params.ang2rad = pi / 180;                    % 角度转弧度系数
subcarrier_num = [-28, -26, -24, -22, -20, -18, -16, ...
    -14, -12, -10, -8, -6, -4, -2, -1, 1, 3, 5, 7, 9, ...
    11, 13, 15, 17, 19, 21, 23, 25, 27, 28];  % 30个子载波的序列号
params.subcarrier_30_freq = zeros(1, 30);     % 30个子载波的频率分布数组
for j = 1:30
    num = subcarrier_num(j);
    freq = params.frequency + num * delta_f;
    params.subcarrier_30_freq(j) = freq;
end

%% 仿真信号生成
simu_signal = zeros(params.N_Rx_antenna, params.N_Rx_subcarrier, params.N_samples);  % 3×30×n
params.pos_antenna = 0:antenna_dis:(params.N_Rx_antenna-1) * antenna_dis; 
simu_phase = zeros(params.N_Rx_antenna, params.N_Rx_subcarrier, params.N_source);  % 3×30×2

% 计算两条信号的相位
for i = 1:params.N_source
    for j = 1:params.N_Rx_subcarrier
        simu_phase(:, j, i) = exp(-1i * 2 * pi * params.subcarrier_30_freq(j) * (simu_path_length(i) / params.c));
        for k = 1:params.N_Rx_antenna
            simu_phase(k, j, i) = simu_phase(k, j, i) * exp(-1i * 2 * pi * (params.subcarrier_30_freq(j)/params.c) * params.pos_antenna(k) * sin(simu_AoA(i) * params.ang2rad));
        end
    end
end

simu_ampl = randn(params.N_source, params.N_samples);  % 仿真(信号源个数×采样点个数)个信号的幅值

% 为两条信号的每个采样点添加幅值
for i = 1:params.N_Rx_antenna
    for j = 1:params.N_Rx_subcarrier
        for k = 1:params.N_samples
            for m = 1:params.N_source
                simu_signal(i, j, k) =  simu_signal(i, j, k)  +  simu_phase(i, j, m) * simu_ampl(m, k);
            end
        end
    end
end

%% 返回csi_data，n×90
csi = permute(simu_signal, [3, 1, 2]);  % n×3×30
params.csi_data = zeros(params.N_samples, 90);  % n×90
params.csi_data(:, 1:30) = reshape(csi(:, 1, :), params.N_samples, 30);
params.csi_data(:, 31:60) = reshape(csi(:, 2, :), params.N_samples, 30);
params.csi_data(:, 61:90) = reshape(csi(:, 3, :), params.N_samples, 30);

end