function main_run_all()
%MAIN_RUN_ALL Execute all analyses, generate figures/metrics/simulink artifacts.
clc;

root = package_root();
codeDir = fullfile(root, 'code');
figDir = fullfile(root, 'figures');
resDir = fullfile(root, 'results');
simDir = fullfile(root, 'simulink');

ensure_dir(codeDir); ensure_dir(figDir); ensure_dir(resDir); ensure_dir(simDir);

p = params_nomoto();
model = nomoto_model(p);

freqMetrics = analyze_frequency_domain(model, figDir);
stepTable = analyze_step_cases(model, figDir);
rampMetrics = analyze_ramp_error(model, figDir);
pidOut = sim_pid_heading(p, model, figDir);
stwOut = sim_stw_heading(p, figDir);
losOut = sim_los_eso_stw(p, figDir);
cmpMetrics = compare_pid_vs_stw(p, model, stwOut, figDir);
simOut = generate_simulink_model(p, model, simDir);

allMetrics = struct();
allMetrics.freq = freqMetrics;
allMetrics.step_cases = stepTable;
allMetrics.ramp = rampMetrics;
allMetrics.pid_stepinfo = pidOut.stepinfo;
allMetrics.compare = cmpMetrics;
allMetrics.simulink = simOut;

save(fullfile(resDir, 'all_metrics.mat'), 'allMetrics', 'pidOut', 'stwOut', 'losOut');
writetable(stepTable, fullfile(resDir, 'step_case_metrics.csv'));

summaryPath = fullfile(resDir, 'metrics_summary.csv');
fid = fopen(summaryPath, 'w');
fprintf(fid, 'Item,Value\n');
fprintf(fid, 'Nomoto_K,%.6f\n', p.K);
fprintf(fid, 'Nomoto_T,%.6f\n', p.T);
fprintf(fid, 'GainMargin,%.6f\n', freqMetrics.GainMargin);
fprintf(fid, 'PhaseMargin_deg,%.6f\n', freqMetrics.PhaseMargin);
fprintf(fid, 'RampSteadyStateError,%.6f\n', rampMetrics.ramp_steady_state_error);
fprintf(fid, 'PID_RMSE_deg,%.6f\n', cmpMetrics.RMSE_PID_deg);
fprintf(fid, 'STW_RMSE_deg,%.6f\n', cmpMetrics.RMSE_STW_deg);
fprintf(fid, 'SimulinkModelCreated,%d\n', simOut.created);
fclose(fid);

simReadme = fullfile(simDir, 'README_Simulink_build.md');
fid = fopen(simReadme, 'w');
fprintf(fid, '# Simulink 构建说明\n\n');
fprintf(fid, '- 目标模型：PID 航向控制 + Nomoto 一阶模型。\n');
fprintf(fid, '- 结构：Step -> Sum(+-) -> PID Controller -> Saturation -> Transfer Fcn -> Scope/To Workspace，输出回负反馈。\n');
fprintf(fid, '- Transfer Fcn：分子 `[K]`，分母 `[T 1 0]`，其中 K=0.1085, T=9.9447。\n');
fprintf(fid, '- Saturation：±35 deg (弧度 ±%.6f)。\n', p.delta_max);
fprintf(fid, '- Step：0 -> 15 deg (0.2618 rad)。\n');
if simOut.created
    fprintf(fid, '- 已自动生成：`%s`。\n', simOut.slx_path);
else
    fprintf(fid, '- 当前环境未检测到可用 Simulink 自动建模能力，请按上述结构手工搭建并保存为 `nomoto_pid_heading.slx`。\n');
end
fclose(fid);

fprintf('main_run_all completed. Outputs generated in: %s\n', root);
end
