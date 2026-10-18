function out = analyze_ramp_error(model, outFigDir)
%ANALYZE_RAMP_ERROR Analyze underdamped case ramp response and SSE.
ensure_dir(outFigDir);

T = 9.9447; K = 0.1085;
Kc_critical = 1/(4*T*K);
Kc_under = 2.0*Kc_critical;
sys_cl = feedback(Kc_under*model.tf, 1);

t = 0:0.1:300;
r = t; % unit ramp
y = lsim(sys_cl, r, t);
e = r - y;

f = figure('Name','Ramp Response and Error','Color','w');
subplot(2,1,1);
plot(t,r,'k--','LineWidth',1.2); hold on;
plot(t,y,'b','LineWidth',1.4);
grid on; xlabel('Time (s)'); ylabel('Output');
legend('Ramp input','System output','Location','best');
title('Underdamped Case Ramp Tracking');

subplot(2,1,2);
plot(t,e,'r','LineWidth',1.4);
grid on; xlabel('Time (s)'); ylabel('Error');
title('Ramp Tracking Error');
save_figure(f, fullfile(outFigDir, 'ramp_response_error_underdamped'));

e_ss = mean(e(end-100:end));
out = struct('Kc', Kc_under, 'ramp_steady_state_error', e_ss);
end
