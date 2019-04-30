close all
clear all
clc

spot = [0.048250 0.043725 0.041694 0.041313];
T = [0.5 1 1.5 2];
d = exp(-spot.*T);

%Forward rate for given spot(zero) rate
for i = 2:length(d)
    f(i) = (spot(i)*T(i)-spot(i-1)*T(i-1))/(T(2)-T(1))
end

a = 0.5;
q = zeros(1,length(d));

[swap_rate,swap_fixed_cost] = Swap_contract(a,f,q,d)






