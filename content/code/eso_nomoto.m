function [z, d_hat] = eso_nomoto(z, psi, delta, p, dt)
%ESO_NOMOTO Linear ESO for heading/yaw-rate/disturbance lumped term.
% States z=[psi_hat; r_hat; d_hat]

beta1 = 3*p.omega0;
beta2 = 3*p.omega0^2;
beta3 = p.omega0^3;

e = z(1) - psi;

z1_dot = z(2) - beta1*e;
z2_dot = z(3) - (1/p.T)*z(2) + (p.K/p.T)*delta - beta2*e;
z3_dot = -beta3*e;

z = z + dt*[z1_dot; z2_dot; z3_dot];
d_hat = z(3);
end
