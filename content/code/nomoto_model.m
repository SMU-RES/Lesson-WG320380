function model = nomoto_model(p)
%NOMOTO_MODEL Build first-order Nomoto heading model representations.
% G_psi(s) = K / ( s * (T s + 1) )
% State-space:
% A=[0 1;0 -1/T], B=[0;K/T], C=[1 0], D=0

A = [0, 1; 0, -1/p.T];
B = [0; p.K/p.T];
C = [1, 0];
D = 0;

s = tf('s');
G = p.K / (s * (p.T*s + 1));

model.A = A;
model.B = B;
model.C = C;
model.D = D;
model.tf = G;
model.ss = ss(A, B, C, D);
end
