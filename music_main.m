clear;
close all;

%%
simu_flag = true; % true/false: 仿真数据/真实数据
params = parameters();

%%
if simu_flag == true
   music_aoa(params.csi_data, params);
   music_tof(params.csi_data, params);
else
    % TODO
end