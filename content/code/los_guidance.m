function psi_d = los_guidance(pos, wp1, wp2, Delta)
%LOS_GUIDANCE Compute desired heading by line-of-sight guidance.
% pos = [x;y], wp1/wp2 are segment endpoints.
chi = atan2(wp2(2)-wp1(2), wp2(1)-wp1(1));
e_ct = -(pos(1)-wp1(1))*sin(chi) + (pos(2)-wp1(2))*cos(chi);
psi_d = wrapToPiLocal(chi - atan2(e_ct, Delta));
end
