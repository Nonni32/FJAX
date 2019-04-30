function [swap_rate,swap_fixed_cost] = Swap_contract(alpha,f_vec,Q_vec,d_vec)
%Swap contract with forward rates

%Q is quantity vec
%f is forward vec
Q = Q_vec;
f = f_vec;
d = d_vec; %vector af discount rate
a = ones(1,length(d))*alpha; % timabil alpha * ones vec

PV_FL = a.*d.*Q.*f;

swap_fixed_cost = PV_FL / sum(a.*Q.*d);
swap_rate = sum(a.*d.*f)/sum(a.*d);

end

