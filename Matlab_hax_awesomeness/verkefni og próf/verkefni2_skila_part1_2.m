%% Part 1
close all
clear all
clc

infl = xlsread('Data.xlsx','1','B12:B2620');
m1_libor = xlsread('Data.xlsx','2','B12:B2620');
m3_libor = xlsread('Data.xlsx','3','B12:B2620');
m12_libor = xlsread('Data.xlsx','4','B12:B2620');

dt = 1/250;

st = 0;
st = infl;
%st = m1_libor
%st = m3_libor;
%st = m12_libor;

st = st(~isnan(st));
T   = 1:1:length(st)-1;

SSx  = st(T);
SSy  = st(T+1);
SSxx = st(T).^2;
SSxy = st(T).*st(T+1);
SSyy = st(T+1).^2;

Sx  = sum(SSx);
Sy  = sum(SSy);
Sxx = sum(SSxx);
Sxy = sum(SSxy);
Syy = sum(SSyy);

est_th = (Sy*Sxx - Sx*Sxy)/( length(st) * (Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
est_k = -(1/dt)*log(( Sxy - est_th*Sx - est_th*Sy + length(st)*est_th^2 )/(  Sxx - 2*est_th*Sx + length(st)*est_th^2 ));

s_hat = (1/length(st))*( Syy - 2*exp(-est_k*dt)*Sxy + exp(-est_k*dt)^2*Sxx - 2*est_th*(1 - exp(-est_k*dt))*(Sy - exp(-est_k*dt)*Sx) + length(st)*est_th^2*(1 - exp(-est_k*dt))^2);
est_sig = sqrt(s_hat*2*est_k/(1 - exp(-est_k*dt)^2));

[est_k est_th est_sig]

%% Part 2
close all
clear all
clc

k = 2;
th = 0.06;
sig = 0.5;

x0 = 0; 
no_itr = 1000000;
dt = 1/250;

[est_k, est_th,est_sig, x_vec] = Ornstein_Uhlenbeck(k,th,sig,x0,dt,no_itr );

x_vec = [x0 x_vec];
x = 0:1:no_itr;
figure(1)
plot(x,x_vec)
title('Ornstein Uhlenbeck')
xlabel('No. Iterations')
ylabel('Dr')

error_K = (est_k - k)^2
error_th = (est_th - th)^2
error_sig = (est_sig - sig)^2

Total_error = error_K + error_th + error_sig