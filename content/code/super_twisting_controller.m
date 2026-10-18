function [u, st_state] = super_twisting_controller(s, st_state, p, dt)
%SUPER_TWISTING_CONTROLLER Discrete super-twisting control law.
v = st_state.v;
v_dot = -p.k2 * sign(s);
v = v + dt*v_dot;
u = -p.k1 * sqrt(abs(s)) * sign(s) + v;
st_state.v = v;
end
