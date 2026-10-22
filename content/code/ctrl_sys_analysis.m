%% 控制系统时域和频域分析
% 开环传递函数：G(s) = K/[s(s+1)(s+2)]
clear; 
clc; 
close all;  

%% 1. 定义系统传递函数
K = 1.5;
num = K;
den = conv([1 0], conv([1 1], [1 2]));  % 分母：s(s+1)(s+2)
G_open = tf(num, den);
G_closed = feedback(G_open, 1);

disp('=== 开环传递函数 ===');
disp(G_open);
disp('=== 闭环传递函数 ===');
disp(G_closed);

%% 2. Bode图
figure('Name','1-Bode图');
bode(G_open);
grid on;
title(['Bode图 (K=', num2str(K), ')']);
margin(G_open);  % 自动标出幅值裕度和相角裕度

%% 3. Nyquist图
figure('Name','2-Nyquist图');
nyquist(G_open);
grid on;
title(['Nyquist图 (K=', num2str(K), ')']);
axis([-3 1 -2 2]);  % 固定坐标轴，方便观察(-1,j0)点

%% 4. 根轨迹图（自动计算临界K）
figure('Name','3-根轨迹图');
rlocus(G_open);
title('根轨迹图');
grid on;

% 用劳斯判据精确计算临界稳定K值（理论值）
% 特征方程：s³ + 3s² + 2s + K = 0
% 劳斯阵列第一列：1, 3, (6-K)/3, K
% 临界条件：(6-K)/3 = 0 → K=6
k_critical = 6;
poles_critical = roots([1 3 2 k_critical]);

disp('=== 正确的临界稳定增益K值 ===');
disp(k_critical);
disp('=== 正确的临界稳定闭环极点 ===');
disp(poles_critical);

% 在图上用红色圆圈自动标出正确的临界稳定点
hold on;
plot(real(poles_critical), imag(poles_critical), 'ro', 'MarkerSize', 12, 'LineWidth', 2);
text(0.1, 1.6, ['K=', num2str(k_critical)], 'FontSize', 14, 'Color', 'red', 'FontWeight', 'bold');
hold off;

%% 5. 不同K值的阶跃响应
figure('Name','4-不同K值阶跃响应');
K_values = [0.5, 1.5, 3, 6];
hold on;
step(feedback(tf(0.5, den), 1), 10, 'b');
step(feedback(tf(1.5, den), 1), 10, 'r');
step(feedback(tf(3, den), 1), 10, 'y');
step(feedback(tf(6, den), 1), 10, 'm');
hold off;
grid on;
legend('K=0.5', 'K=1.5', 'K=3', 'K=6', 'Location', 'southeast');
title('不同K值下的单位阶跃响应');
xlabel('时间 (秒)');
ylabel('输出');

%% 6. 斜坡响应稳态误差
Kv = K / 2;
ess_ramp = 1 / Kv;

disp('=== 斜坡响应稳态误差分析 ===');
disp(['速度误差系数 Kv = ', num2str(Kv)]);
disp(['单位斜坡输入稳态误差 ess = ', num2str(ess_ramp)]);

disp(' ');
disp('=== 最终实验结论 ===');
disp('当 0 < K < 6 时，系统稳定');
disp('当 K ≥ 6 时，系统不稳定');
disp('增大K：响应变快，误差减小，但超调量增大，稳定性下降');