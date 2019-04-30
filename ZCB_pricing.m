function [P_at_1year, mu_P, sig_P, C_0, P_0] = ZCB_pricing(T,T_2,all_rates,sigma,r_term,k)
N2 = T_2*252;
N = T*252;
x = 1:N2; 

% Valuating the price of the zero coupon bond at time T = 1 year
for i = 1:size(all_rates,1)
    dt = 1/252;
    for j = 1:N2
        P(i,j) = exp(-all_rates(i,j).*(T-dt)+(1./6)*sigma.^2.*(T-dt).^2);
        dt = dt + 1/252;
        y(i,j) = P(i,j);
    end
    dt = 1/252;
    for j = 1:N
        P(i,j) = exp(-all_rates(i,j).*(T-dt)+(1./6)*sigma.^2.*(T-dt).^2);
        dt = dt + 1/252;
        yy(i,j) = P(i,j);
    end
    P_at_1year(i) = y(i,N2);
end

% this for loop can be used to see how the bond price matures from t = 0 to
% T = 1;
% figure
% for i = 1:size(all_rates,1)
%     plot(x,y(i,:))
%     hold on
%     xlabel('Time [days] from day 0 to T = 1 year');
%     ylabel('Bond price evolution');
%     title('Bond price at each day for maturity at time 2 years');
% end

%ploting the price of the bond at each day over the time period
figure
x = 1:N;
for i = 1:size(all_rates,1)
    plot(x,yy(i,:))
    hold on
    xlabel('Time [days] from day 0 to T = 2 years');
    ylabel('Bond price evolution');
    title('Bond price at each day for maturity at time 2 years');
end

%Distribution of the bond price from the simulated results at T = 1 year
figure
histfit(P_at_1year,100)
xlabel('Simulated Bond Price at t = 1 year')
ylabel('Frequency')
title('Histogram of simulated Bond Price results')
[mu_P, sig_P] = normfit(P_at_1year);


% This is the Monte Carlo simulation for the call and put prices
for i = 1:length(P_at_1year)
    C_N(i) = max([P_at_1year(i)-k, 0]);
    P_N(i) = max([k-P_at_1year(i), 0]);
end
C_mean = mean(C_N);
P_mean = mean(P_N);
C_0 = C_mean*exp(-r_term*T_2);
P_0 = P_mean*exp(-r_term*T_2)

end