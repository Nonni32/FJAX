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
        calculatedCall
        calculatedPut
    end
    
    methods
        function obj = pricingModel(interestRateModel, strikePrice, optionMaturity)
            %obj.contractType = contractType;
            obj.interestRateModel = interestRateModel;
            obj.strikePrice = strikePrice;
            obj.optionMaturity = optionMaturity;
            obj.maturity = interestRateModel.maturity; 
            
            [obj.simulatedBonds, obj.simulatedBondPrices] = obj.zeroCouponBondSimulation;
            [obj.simulatedCalls, obj.simulatedPuts] = obj.optionSimulation;
            [obj.calculatedCall, obj.calculatedPut] = obj.blackScholesPricer;
        end
        
        function [B, bT] = zeroCouponBondSimulation(obj)
            % ZERO COUPON SIMULATION
            interestRateModel = obj.interestRateModel;
            r0 = interestRateModel.initialRate;
            dt = interestRateModel.stepSize;
            sigma = interestRateModel.volatility;
            T = interestRateModel.maturity;
            N = interestRateModel.nrOfSimulations;

            L = T/dt;
            B = zeros(N,L); 
            bT = zeros(1,N);
            R = interestRateModel.data;
            
            switch interestRateModel.model
                case "Simple"
                    for i = 1:N 
                        for j = 1:L
                            B(i,j) = exp(-R(i,j)*((L-(j-1))*dt)+(1/6)*sigma^2*((L-(j-1))*dt)^3);
                        end
                        bT(1,i) = B(i,L);
                    end 
                case "Brownian"
                    alpha = interestRateModel.longTermMeanLevel;
                    for i = 1:N 
                        for j = 1:L
                            B(i,j) = exp(-R(i,j)*((L-(j-1))*dt)-(1/2)*alpha*((L-(j-1))*dt)^2+(1/6)*sigma^2*((L-(j-1))*dt)^3);
                        end
                        bT(1,i) = B(i,L);
                    end 
                case "Vasicek"
                    kappa = interestRateModel.speedOfReversion;
                    theta = interestRateModel.longTermMeanLevel;
                    
                    for i = 1:N 
                        for j = 1:L
                            BtT = (1/kappa)*(1-exp(-kappa*(L-(j-1))*dt));
                            AtT = exp((theta-(sigma^2)/(2*kappa^2))*(BtT-(L-(j-1))*dt)-((sigma^2)/(4*kappa))*BtT);
                            B(i,j) = AtT*exp(-R(i,j)*BtT);
                        end
                        bT(1,i) = B(i,L);
                    end      
            end
        end
        
        function [callPrice, putPrice] = optionSimulation(obj)
            K = obj.strikePrice;
            T = obj.optionMaturity;
            N = T/obj.interestRateModel.stepSize; 
            callPayoff = max(obj.simulatedBonds(end,1:N)-K,1);
            putPayoff = max(K-obj.simulatedBonds(end,1:N),0);
            
            r0 = obj.interestRateModel.initialRate;
            callPrice = mean(exp(-r0*T)*callPayoff); 
            putPrice = mean(exp(-r0*T)*putPayoff); % HALLO
        end
        
        
        function obj = optionPathSimulation(obj)
            T = obj.optionMaturity;
            R = obj.interestRateModel.data;
            K = obj.strikePrice;
            dt = obj.interestRateModel.stepSize;
            
            dates = linspace(today(),today()+365*T, length(R));
            callPricePath = zeros(1,length(R));
            putPricePath = zeros(1,length(R));
            
            for i = 1:length(R)
                callPayoff = max(obj.simulatedBonds(end,:)-K,0);
                putPayoff = max(K-obj.simulatedBonds(end,:),0);
                r = mean(R(:,i));
                callPricePath(i) = exp(-r*(T-i*dt))*sum(callPayoff)/length(callPayoff);
                putPricePath(i) = exp(-r*(T-i*dt))*sum(putPayoff)/length(putPayoff);
            end
            plot(dates, callPricePath,'r-')
            hold on
            plot(dates, putPricePath,'b-')
            datetick('x','dd/mm/yyyy')
            grid on
            xlim([today() today()+365*T])
            legend('Call option','Put option')
        end
        
        
        function plotBonds(obj)
            N = obj.interestRateModel.nrOfSimulations;
            dates = linspace(today(),today()+365*obj.maturity, length(obj.interestRateModel.data));
            for i = 1:N
                plot(dates,obj.simulatedBonds(i,:),'HandleVisibility','off')
                hold on
            end
            K = obj.strikePrice;
            plot([min(dates) max(dates)],[K K],'k-','LineWidth',1.5)
            datetick('x','dd/mm/yyyy')
            legend('Strike price')
            grid on
            xlim([min(dates) max(dates)])
        end
        
        function [C, P] = blackScholesPricer(obj)    
            model = obj.interestRateModel;
            dt = obj.interestRateModel.stepSize;
            sigma = obj.interestRateModel.volatility;
            S = obj.maturity; % S > T
            T = obj.optionMaturity;
            B = obj.simulatedBonds(1,1);
            R = obj.interestRateModel.data;
            K = obj.strikePrice;
            rT = mean(R(:,T));
            rS = mean(R(:,S));

            % Call
            switch model.model
                case "Simple"
                    d1 = (log(B/K) + (R(1,1) + 0.5*sigma^2)*S)/(sigma*sqrt(S));
                    d2 = d1 - sigma*sqrt(S);
                    N1 = 0.5*(1+erf(d1/sqrt(2)));
                    N2 = 0.5*(1+erf(d2/sqrt(2)));
                    C = B*N1-K*exp(-R(1,1)*S)*N2;
                    % Put
                    N1 = 0.5*(1+erf(-d1/sqrt(2)));
                    N2 = 0.5*(1+erf(-d2/sqrt(2)));
                    P = K*exp(-R(1,1)*S)*N2 - B*N1;
                case "Brownian"
                    alpha = model.longTermMeanLevel;
                    PtT = exp(-rT*T-(1/2)*alpha*T^2+(1/6)*sigma^2*T^3);
                    PtS = exp(-rT*S-(1/2)*alpha*S^2+(1/6)*sigma^2*S^3);
                    d1 = (log(PtS/(K*PtT))+(1/2)*sigma^2*((S-T)^2)*T)/(sigma*(S-T)*sqrt(T));
                    d2 = d1 - sigma*(S-T)*sqrt(T);            

                    N1 = 0.5*(1+erf(d1/sqrt(2)));
                    N2 = 0.5*(1+erf(d2/sqrt(2)));
                    C = B*N1-K*exp(-R(1,1)*S)*N2;
                    % Put
                    N1 = 0.5*(1+erf(-d1/sqrt(2)));
                    N2 = 0.5*(1+erf(-d2/sqrt(2)));
                    P = K*exp(-R(1,1)*S)*N2 - B*N1;
                case "Vasicek"
                    Q = 1; % Principal of the bond
                    kappa = model.speedOfReversion;
                    theta = model.longTermMeanLevel;

                    BtT = (1/kappa)*(1-exp(-kappa*T));
                    BtS = (1/kappa)*(1-exp(-kappa*S));
                    AtT = exp((theta-(sigma^2)/(2*kappa^2))*(BtT-T)-((sigma^2)/(4*kappa))*BtT);
                    AtS = exp((theta-(sigma^2)/(2*kappa^2))*(BtS-S)-((sigma^2)/(4*kappa))*BtT);
                    rt = R(1,1);

                    PtT = AtT*exp(-rt*BtT);
                    PtS = AtS*exp(-rt*BtS);

                    sigmaP = (sigma/kappa)*(1-exp(-kappa*(S-T)))*sqrt((1-exp(-2*kappa*T)/(2*kappa)));
                    d = (1/sigmaP)*log((Q*PtS)/(K*PtT))+sigmaP/2;

                    N = @(x) 0.5*(1+erf(-x/sqrt(2)));

                    C = Q*PtS*N(d)-K*PtT*N(d-sigmaP);
                    P = K*PtT*N(-d+sigmaP)-Q*PtS*N(-d);            
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
