function out = sim_stw_heading(p, outFigDir)
%SIM_STW_HEADING Heading control with ESO + super-twisting under disturbance.
ensure_dir(outFigDir);

t = 0:p.dt:p.t_end;
n = numel(t);

psi = zeros(1,n);
r = zeros(1,n);
delta = zeros(1,n);
delta_pid = zeros(1,n);
psi_ref = p.r_ref*ones(1,n);

z = [0;0;0];
st.v = 0;

% PID baseline for later comparison
Kp = 6; Ki = 0.08; Kd = 30;
e_int = 0; e_prev = 0;

for k = 1:n-1
    dk = 0.02*sin(0.03*t(k)) + (t(k)>200)*0.015; % matched disturbance
    e = wrapToPiLocal(psi(k)-psi_ref(k));

    [z, d_hat] = eso_nomoto(z, psi(k), delta(max(k-1,1)), p, p.dt);
    s = p.c*e + z(2); % simple sliding surface
    [u_stw, st] = super_twisting_controller(s, st, p, p.dt);
    delta_cmd = -(p.T/p.K)*(u_stw + d_hat);
    delta(k) = max(min(delta_cmd, p.delta_max), -p.delta_max);

    r_dot = -(1/p.T)*r(k) + (p.K/p.T)*delta(k) + dk;
    r(k+1) = r(k) + p.dt*r_dot;
    psi(k+1) = wrapToPiLocal(psi(k) + p.dt*r(k));

    % PID simulation on same disturbed plant
    e_pid = wrapToPiLocal(psi_ref(k)-psi(k));
    e_int = e_int + e_pid*p.dt;
    e_der = (e_pid - e_prev)/p.dt;
    e_prev = e_pid;
    dpid = Kp*e_pid + Ki*e_int + Kd*e_der;
    delta_pid(k) = max(min(dpid, p.delta_max), -p.delta_max);
end

f = figure('Name','STW Heading Tracking','Color','w');
subplot(2,1,1);
plot(t, rad2deg(psi_ref), 'k--', 'LineWidth',1.2); hold on;
plot(t, rad2deg(psi), 'b', 'LineWidth',1.4);
grid on; ylabel('Heading (deg)'); legend('Reference','ESO+STW');
title('ESO + Super-Twisting Heading Control');

subplot(2,1,2);
plot(t, rad2deg(delta), 'r', 'LineWidth',1.2);
grid on; xlabel('Time (s)'); ylabel('Rudder (deg)');
title('ESO+STW Rudder Command');
save_figure(f, fullfile(outFigDir, 'stw_heading_response'));

out = struct('t',t,'psi',psi,'psi_ref',psi_ref,'delta_stw',delta,'delta_pid',delta_pid);
end
