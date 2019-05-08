classdef pricingModel
    % Class for pricing
    properties
        interestRateModel
        maturity
        
    end
    
    methods
        function simulation(obj, contractType, interestRateModel, nrOfSimulations)
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end


function [R, rT] = interest_rate_simulation(r0, dt, sigma, T, N)
    % INTEREST RATE SIMULATION
    % model: dRt = sigmadWt
    L = T/dt; 
    R = zeros(N,L);
    rT = zeros(1,N);
    for i = 1:N
        R(i,1) = r0;
        for j = 2:L
            dR = sigma*sqrt(dt)*randn;
            R(i,j) = R(i,j-1)+dR;
        end
        rT(1,i) = R(i,L);
    end
end

function [B, bT] = zero_coupon_bond_simulation(r0, dt, sigma, T, N)
    % ZERO COUPON SIMULATION
    % Model: B(t,T) = exp(-r(t)(T-t)+(1/6)sigma^2(T-t)^3
    L = T/dt;
    B = zeros(N,L); 
    bT = zeros(1,N);
    R = interest_rate_simulation(r0, dt, sigma, T, N);
    for i = 1:N 
        for j = 1:L
            B(i,j) = exp(-R(i,j)*((L-1)*dt)+(1/6)*sigma^2*((L-1)*dt)^3);
        end
        bT(1,i) = B(i,L);
    end 
end

function [C, P, B] = option_simulation(r0, dt, sigma, T, K, N)
    % CALL AND PUT OPTION SIMULATION
    [B, bT] = zero_coupon_bond_simulation(r0, dt, sigma, T, N);
    c_payoff = max(bT(1,:)-K,0);
    p_payoff = max(K-bT(1,:),0);
    
    C = exp(-r0*T)*sum(c_payoff)/N;
    P = exp(-r0*T)*sum(p_payoff)/N;
end

function P = put_option_simulation(r0, dt, sigma, T, K, N)
    % PUT OPTION SIMULATION
    p0 = zeros(1,N);
    [B, bT] = zero_coupon_bond_simulation(r0, dt, sigma, T, N);
    payoff = max(K-bT(1,:),0);
    P = exp(-r0*T)*sum(payoff)/N;
end
