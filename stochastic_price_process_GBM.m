function [final_day] = stochastic_price_process_GBM(days,simulations,dt,mu,sigma,s_0)

%Stochastic price process
%ds(t) = mu * s(t)* dt + sig * s(t) * dW(t)
figure(1)
for k = 1:simulations 
    N = days;
    s = s_0;
    ds = 0;
    y_vec = 0;
    for i = 1:N
        ds = mu * s * dt + sigma * s * randn() * sqrt(dt);
        s = s + ds;
        y_vec(i) = s;
    end    
    final_day(k) = y_vec(N);
    x = 1:N;
    plot(x,y_vec)
    xlabel('Time [days]');
    ylabel('Value evolution with mean path');
    title('Stochastic price process');
    hold on
end

s = 100;
figure(2)
histogram(final_day,100,'Normalization','Probability');
xlabel('Value')
ylabel('Probability')
title('Stochastic price process Histogram')
end

