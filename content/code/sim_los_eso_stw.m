function out = sim_los_eso_stw(p, outFigDir)
%SIM_LOS_ESO_STW 2D path tracking with LOS guidance and heading STW loop.
ensure_dir(outFigDir);

t = 0:p.dt:800;
n = numel(t);
u0 = 2.0; % surge speed (m/s, constant)

x = zeros(1,n); y = zeros(1,n);
psi = zeros(1,n); r = zeros(1,n); delta = zeros(1,n);

wp1 = [0; 0]; wp2 = [1000; 0];
Delta = 60;

z = [0;0;0]; st.v = 0;

for k = 1:n-1
    psi_d = los_guidance([x(k);y(k)], wp1, wp2, Delta);
    e = wrapToPiLocal(psi(k)-psi_d);

    [z, d_hat] = eso_nomoto(z, psi(k), delta(max(k-1,1)), p, p.dt);
    s = p.c*e + z(2);
    [u_stw, st] = super_twisting_controller(s, st, p, p.dt);
    delta_cmd = -(p.T/p.K)*(u_stw + d_hat);
    delta(k) = max(min(delta_cmd, p.delta_max), -p.delta_max);

    dk = 0.01*sin(0.02*t(k));
    r_dot = -(1/p.T)*r(k) + (p.K/p.T)*delta(k) + dk;
    r(k+1) = r(k) + p.dt*r_dot;
    psi(k+1) = wrapToPiLocal(psi(k) + p.dt*r(k));

    x(k+1) = x(k) + p.dt*u0*cos(psi(k));
    y(k+1) = y(k) + p.dt*u0*sin(psi(k));
end

f = figure('Name','LOS Path Tracking','Color','w');
plot(x,y,'b','LineWidth',1.4); hold on;
plot([wp1(1),wp2(1)],[wp1(2),wp2(2)],'k--','LineWidth',1.2);
grid on; axis equal;
xlabel('x (m)'); ylabel('y (m)');
legend('Tracked path','Reference path','Location','best');
title('LOS + ESO + Super-Twisting Path Tracking');
save_figure(f, fullfile(outFigDir, 'los_path_tracking'));

out = struct('t',t,'x',x,'y',y,'psi',psi,'delta',delta);
end
