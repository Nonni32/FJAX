function [rates_T, mu, sig, rates] = Wiener_for_rates(sigma, T, r_0,simulations)
%dr(t) = sigma*dW(t)
%P(t,T) = exp(-heildi frá t uppí T af (r(s)ds))

% Dagafjöldi í ári
t = 252;
dt = 1/t;
N = T*t;
Total_days = 1:N;

%simulating rates for each day
for sim = 1:simulations 
    r = r_0;
    for day = 1:N
        dr = sigma * randn() * sqrt(dt);
        r = r + dr; 
        rates(sim,day) = r;
    end  
    rates_T(sim) = rates(sim,N); %rates at time T
end

%ploting the simulated rates
figure
for sim = 1:simulations
    plot(Total_days,rates(sim,:))
    hold on
    xlabel('Time [days]');
    ylabel('Term rate evolution');
    title('Wiener process for the term rate');
end

%ploting the distribution of the rates
figure
histfit(rates_T,100)
xlabel('Simulated rate of return after 2 years')
ylabel('Frequency')
title('Histogram of simulated results')
%the mean and sigma of the simulated rates at time T
[mu, sig] = normfit(rates_T);

end