% nor=mal and log-normal distributions
%histogram

%%
clear all
close all
clc
%% Interest in a bank.
x = input('Money into bank account   ');
t = input('how much time in years?   ');
r = input('annual fixed rate   ');

X = x*exp(r*t);

fprintf('The value of your money will be $%.2f after %.2f years.',X,t)

%% Stochastic price processes
%Asset price evolution is presented by the following stochastic
%differential equation (SDE)
%dS(t) = mu*S(t)dt + sigma*S(t)dW(t)

S0 = 100; % spot price
sigma = 0.25; % Standard deviation
mu = 0.1; % mean
T = 1300; % days to maturity
dt = 1/252; % days in one year
sim = 10; % number of simulations

[final_day_price] = stochastic_price_process_GBM(T,sim,dt,mu,sigma,S0);

%% Wiener process for spot rate // verkefni 3 part 1
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

%% Itó's Lemma
%f(S) = logS(t)
%dlogS(t) = [mu-(sigma^2/2)]dt + sigmadW(t))
%logS(T) = logS(t) + [mu-(sigma^2/2)](T-t)+sigma(W(T)-W(t))
S0 = 100;
sigma = 0.25;
mu = 0.1;
t = 0;
T = 3;
Expected_logS_T = ln(S0)+(mu-(sigma^2/2))*(T-t);
var_logS_T = sigma^2*(T-t);


%% Normal and log-normal distributions
%Histogram
%% pricing call and put options
P = 100; % Price
k = 105; % strike price
r = 0.05; % interest rate
T = 0.25; % time to maturity in years
v = 0.25; % volatility
y = 0.045; % yield
[call, put] = blsprice(P,k,r,T,v); %pricing of call and put without yield
%[call, put] = blsprice(P,k,r,T,v,y); %pricing of call and put with yield

%% Geometric brownian motion
r = 0.055;
sigma = 0.05;
ar = 2;
MDL = gbm(r,sigma);
[Paths, Times, Z] = simByEuler(MDL, ar);
