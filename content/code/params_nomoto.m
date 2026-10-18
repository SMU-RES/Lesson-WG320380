function p = params_nomoto()
%PARAMS_NOMOTO Fixed model and controller parameters from assignment/literature.
p.K = 0.1085;
p.T = 9.9447;

% LOS + ESO + STW reference parameters from literature summary
p.c = 2;
p.k1 = 0.1;
p.k2 = 0.01;
p.omega0 = 0.1;

% generic limits/sim settings
p.delta_max = deg2rad(35);  % rudder saturation
p.r_ref = deg2rad(15);      % default heading step command
p.t_end = 500;
p.dt = 0.05;
end
