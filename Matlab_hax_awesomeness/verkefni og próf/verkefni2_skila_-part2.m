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
