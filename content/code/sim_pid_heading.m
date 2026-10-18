function out = sim_pid_heading(p, model, outFigDir)
%SIM_PID_HEADING Simulate heading step tracking with PID controller.
ensure_dir(outFigDir);

% conservative hand-tuned PID for stable performance
Kp = 6.0;
Ki = 0.08;
Kd = 30.0;
C = pid_controller(Kp, Ki, Kd);
sys_cl = feedback(C*model.tf, 1);

t = 0:0.1:400;
r = p.r_ref * ones(size(t));
y = lsim(sys_cl, r, t);

% Use explicit time-domain PID command to avoid non-proper transfer simulation issues.
e = r(:) - y(:);
e_int = cumtrapz(t(:), e);
e_der = [0; diff(e)./diff(t(:))];
u = Kp*e + Ki*e_int + Kd*e_der;
u = u(:).';
u_sat = max(min(u, p.delta_max), -p.delta_max);

f = figure('Name','PID Heading Response','Color','w');
subplot(2,1,1);
plot(t, rad2deg(r), 'k--', 'LineWidth', 1.2); hold on;
plot(t, rad2deg(y), 'b', 'LineWidth', 1.4);
grid on; ylabel('Heading (deg)');
legend('Reference','Heading','Location','best');
title('PID Heading Tracking');

subplot(2,1,2);
plot(t, rad2deg(u_sat), 'm', 'LineWidth', 1.4);
grid on; xlabel('Time (s)'); ylabel('Rudder angle (deg)');
title('PID Rudder Command (with Saturation)');
save_figure(f, fullfile(outFigDir, 'pid_heading_response'));

info = stepinfo(y, t, p.r_ref);
out = struct('Kp',Kp,'Ki',Ki,'Kd',Kd,'stepinfo',info,'t',t,'r',r,'y',y,'u',u_sat,'C',C,'sys_cl',sys_cl);
end
