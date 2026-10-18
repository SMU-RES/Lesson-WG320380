function metrics = compare_pid_vs_stw(p, model, stwOut, outFigDir)
%COMPARE_PID_VS_STW Compare PID and ESO+STW under same disturbance scenario.
ensure_dir(outFigDir);

t = stwOut.t;
n = numel(t);
psi_pid = zeros(1,n);
r_pid = zeros(1,n);
delta_pid = zeros(1,n);
psi_ref = stwOut.psi_ref;

Kp = 6; Ki = 0.08; Kd = 30;
e_int = 0; e_prev = 0;

for k = 1:n-1
    e_pid = wrapToPiLocal(psi_ref(k)-psi_pid(k));
    e_int = e_int + e_pid*p.dt;
    e_der = (e_pid - e_prev)/p.dt;
    e_prev = e_pid;

    delta_cmd = Kp*e_pid + Ki*e_int + Kd*e_der;
    delta_pid(k) = max(min(delta_cmd, p.delta_max), -p.delta_max);

    dk = 0.02*sin(0.03*t(k)) + (t(k)>200)*0.015;
    r_dot = -(1/p.T)*r_pid(k) + (p.K/p.T)*delta_pid(k) + dk;
    r_pid(k+1) = r_pid(k) + p.dt*r_dot;
    psi_pid(k+1) = wrapToPiLocal(psi_pid(k) + p.dt*r_pid(k));
end

e_pid = wrapToPiLocal(psi_ref - psi_pid);
e_stw = wrapToPiLocal(psi_ref - stwOut.psi);

f1 = figure('Name','PID vs STW Disturbance Comparison','Color','w');
plot(t, rad2deg(e_pid), 'r', 'LineWidth',1.2); hold on;
plot(t, rad2deg(e_stw), 'b', 'LineWidth',1.2);
grid on; xlabel('Time (s)'); ylabel('Heading error (deg)');
legend('PID','ESO+STW','Location','best');
title('Disturbance Rejection: PID vs ESO+STW');
save_figure(f1, fullfile(outFigDir, 'pid_vs_stw_disturbance'));

f2 = figure('Name','Rudder Angle Comparison','Color','w');
plot(t, rad2deg(delta_pid), 'r', 'LineWidth',1.2); hold on;
plot(t, rad2deg(stwOut.delta_stw), 'b', 'LineWidth',1.2);
grid on; xlabel('Time (s)'); ylabel('Rudder angle (deg)');
legend('PID','ESO+STW','Location','best');
title('Rudder Angle Comparison');
save_figure(f2, fullfile(outFigDir, 'rudder_angle_comparison'));

rmse_pid = sqrt(mean(e_pid.^2));
rmse_stw = sqrt(mean(e_stw.^2));
metrics = struct('RMSE_PID_rad', rmse_pid, 'RMSE_STW_rad', rmse_stw, ...
    'RMSE_PID_deg', rad2deg(rmse_pid), 'RMSE_STW_deg', rad2deg(rmse_stw));
end
