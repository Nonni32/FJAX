%% Wiener process
clear all
close all
clc

P_T = 1; % pays 1 $ at maturity
sigma = 0.05;
t = 0;
T_1year = 1; % Time to find Bond Price at.
T = 2; % Time to maturity in years
k = 0.975; %Strike price
r_0 = 0.055; % Spot rate at time t = 0
term_rate = r_0-(1/6)*sigma^2*(T_1year-t)^2;
simulations = 1000; % No. of simulations.

[rate_T, mu_sim, sig_sim, all_rates] = Wiener_for_rates(sigma,T,r_0,simulations);
[final_P, mu_P, sig_P,call_monte, put_monte] = ZCB_pricing(T,T_1year,all_rates,sigma,term_rate,k);
mu_P_0 = mu_P*exp(-term_rate*T_1year); % average simulated price at t = 1 discounted

% black scholes pricing of call and put options
[call_BLS, put_BLS] = blsprice(mu_P_0,k,r_0,T_1year,sigma);