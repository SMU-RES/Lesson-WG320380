function tbl = analyze_step_cases(model, outFigDir)
%ANALYZE_STEP_CASES Overdamped/underdamped/critical responses and metrics.
ensure_dir(outFigDir);

% Closed-loop denominator: T s^2 + s + K*Kc = 0
% zeta = 1/(2*sqrt(T*K*Kc))
T = 9.9447; K = 0.1085;

Kc_critical = 1/(4*T*K);
Kc_over = 0.5*Kc_critical;
Kc_under = 2.0*Kc_critical;

sys_over = feedback(Kc_over*model.tf, 1);
sys_crit = feedback(Kc_critical*model.tf, 1);
sys_under = feedback(Kc_under*model.tf, 1);

t = 0:0.1:300;
[y_over, t_over] = step(sys_over, t);
[y_crit, t_crit] = step(sys_crit, t);
[y_under, t_under] = step(sys_under, t);

f = figure('Name','Step Damping Cases','Color','w');
plot(t_over,y_over,'LineWidth',1.4); hold on;
plot(t_crit,y_crit,'LineWidth',1.4);
plot(t_under,y_under,'LineWidth',1.4);
grid on; xlabel('Time (s)'); ylabel('\psi (rad)');
legend('Overdamped','Critical','Underdamped','Location','best');
title('Step Responses: Overdamped / Critical / Underdamped');
save_figure(f, fullfile(outFigDir, 'step_damping_cases'));

info_over = stepinfo(sys_over);
info_crit = stepinfo(sys_crit);
info_under = stepinfo(sys_under);

ess_over = abs(1 - dcgain(sys_over));
ess_crit = abs(1 - dcgain(sys_crit));
ess_under = abs(1 - dcgain(sys_under));

tbl = table( ...
    ["Overdamped";"Critical";"Underdamped"], ...
    [Kc_over;Kc_critical;Kc_under], ...
    [info_over.Overshoot;info_crit.Overshoot;info_under.Overshoot], ...
    [info_over.PeakTime;info_crit.PeakTime;info_under.PeakTime], ...
    [info_over.SettlingTime;info_crit.SettlingTime;info_under.SettlingTime], ...
    [ess_over;ess_crit;ess_under], ...
    'VariableNames', {'Case','Kc','Overshoot_percent','PeakTime_s','SettlingTime_s','SteadyStateError'});
end
