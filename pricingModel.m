classdef pricingModel
    % Class for pricing
    properties
        %contractType
        interestRateModel
        maturity
        optionMaturity
        simulatedBonds
        simulatedBondPrices
        calculatedBondPrices
        strikePrice
        simulatedCalls
        simulatedPuts
        
    end
    
    methods
        function obj = simulation(obj, interestRateModel, strikePrice, optionMaturity)
            %obj.contractType = contractType;
            obj.interestRateModel = interestRateModel;
            obj.strikePrice = strikePrice;
            obj.optionMaturity = optionMaturity;
            obj.maturity = interestRateModel.maturity; 
            
            [obj.simulatedBonds, obj.simulatedBondPrices] = zeroCouponSimulator;
            
        end
        
        function [B, bT] = zeroCouponBondSimulation(obj)
            % ZERO COUPON SIMULATION
            interestRateModel = obj.interestRateModel;
            r0 = interestRateModel.initialRate;
            dt = interestRateModel.stepSize;
            sigma = interestRateModel.volatility;
            T = interestRateModel.maturity;
            N = interestRateModel.nrOfsimulations;

            L = T/dt;
            B = zeros(N,L); 
            bT = zeros(1,N);
            R = interestRateModel.data;
            
            switch interestRateModel.model
                case "Simple"
                    for i = 1:N 
                        for j = 1:L
                            B(i,j) = exp(-R(i,j)*((L-1)*dt)+(1/6)*sigma^2*((L-1)*dt)^3);
                        end
                        bT(1,i) = B(i,L);
                    end 
                case "Brownian"
                    alpha = interestRateModel.longTermMeanLevel;
                    
                    for i = 1:N 
                        for j = 1:L
                            B(i,j) = exp(-R(i,j)*((L-1)*dt)-(1/2)*alpha*((L-1)*dt)^2+(1/6)*sigma^2*((L-1)*dt)^3);
                        end
                        bT(1,i) = B(i,L);
                    end 
                case "Vasicek"
                    kappa = interestRateModel.speedOfReversion;
                    theta = interestRateModel.longTermMeanLevel;
                    
                    for i = 1:N 
                        for j = 1:L
                            BtT = (1/kappa)*(1-exp(-kappa*(L-1)*dt));
                            AtT = exp((theta-(sigma^2)/(2*kappa^2))*(BtT-(L-1)*dt)-((sigma^2)/(4*kappa))*BtT);
                            B(i,j) = AtT*exp(-R(i,j)*BtT);
                        end
                        bT(1,i) = B(i,L);
                    end      
            end
        end
    end
end


function [C, P, B] = optionSimulation(r0, dt, sigma, T, K, N)
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
