function C = pid_controller(Kp, Ki, Kd)
%PID_CONTROLLER Return PID transfer function C(s) = Kp + Ki/s + Kd s.
s = tf('s');
C = Kp + Ki/s + Kd*s;
end
