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
            [obj.calculatedCall, obj.calculatedPut] = obj.optionPricer(0);
        end
        
        function [B, bT] = zeroCouponBondSimulation(obj)
            % ZERO COUPON SIMULATION
            interestRateModel = obj.interestRateModel;
            r0 = interestRateModel.initialRate;
            dt = interestRateModel.stepSize;
            sigma = interestRateModel.volatility;
            T = interestRateModel.maturity;
            N = interestRateModel.nrOfSimulations;
            O = obj.optionMaturity;
            
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
                        bT(1,i) = B(i,O/dt);
                    end 
                case "Brownian"
                    alpha = interestRateModel.longTermMeanLevel;
                    for i = 1:N 
                        for j = 1:L
                            B(i,j) = exp(-R(i,j)*((L-(j-1))*dt)-(1/2)*alpha*((L-(j-1))*dt)^2+(1/6)*sigma^2*((L-(j-1))*dt)^3);
                        end
                        bT(1,i) = B(i,O/dt);
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
                        bT(1,i) = B(i,O/dt);
                    end      
            end
        end
        
        %Option Simulation
        function [callPrice, putPrice] = optionSimulation(obj)
            K = obj.strikePrice;
            T = obj.optionMaturity;
            N = T/obj.interestRateModel.stepSize; 
            callPayoff = mean(max(obj.simulatedBonds(:,N)-K,0));
            putPayoff = mean(max(K-obj.simulatedBonds(:,N),0));
            
            %Skoða þetta ... og eitthvað meira
            r0 = obj.interestRateModel.initialRate;
            callPrice = exp(-r0*T)*callPayoff;
            putPrice = exp(-r0*T)*putPayoff; 
        end
        
        function obj = optionPathSimulation(obj)
            call = [];
            put = [];
            dt = obj.interestRateModel.stepSize;
            for i = 0:dt:obj.optionMaturity
                [call(end+1), put(end+1)] = obj.optionPricer(i);
            end
            plot(call)
            hold on
            plot(put)
        end
        
        
        function plotBonds(obj)
            N = obj.interestRateModel.nrOfSimulations;
            dates = linspace(today(),today()+365*obj.maturity, 250*obj.maturity);
            for i = 1:N
                plot(dates,obj.simulatedBonds(i,:),'HandleVisibility','off')%,'Color',[0.5 0.5 0.5])
                hold on
            end
            K = obj.strikePrice;
            plot([min(dates) max(dates)],[K K],'k-','LineWidth',1.5)
            plot(today+365*obj.optionMaturity,K,'k+','LineWidth',5)
            datetick('x','dd/mm/yyyy')
            legend('Strike price','Exercise date')
            grid on
            xlim([min(dates) max(dates)])
        end

        function [C, P] = optionPricer(obj,t)    
            
            model = obj.interestRateModel;
            dt = obj.interestRateModel.stepSize;
            sigma = obj.interestRateModel.volatility;
            
            S = obj.maturity-t; % S > T
            T = obj.optionMaturity-t;
            
            B = obj.simulatedBonds(1,1); %starting price
            R = obj.interestRateModel.data;
            K = obj.strikePrice;
            
            rt = obj.interestRateModel.initialRate;
            rT = mean(R(:,(T+t)/dt));
            rS = mean(R(:,(S+t)/dt));

            % Call
            switch model.model
                case "Simple"
%                     d1 = (log(B/K) + (R(1,1) + 0.5*sigma^2)*T)/(sigma*sqrt(T));
%                     d2 = d1 - sigma*sqrt(T); %Breytti úr S í T líka fyrir ofan
%                     N1 = 0.5*(1+erf(d1/sqrt(2)));
%                     N2 = 0.5*(1+erf(d2/sqrt(2)));
%                     C = B*N1-K*exp(-R(1,1)*T)*N2; %Breytti úr S í T
%                     % Put
%                     N1 = 0.5*(1+erf(-d1/sqrt(2)));
%                     N2 = 0.5*(1+erf(-d2/sqrt(2)));
%                     P = K*exp(-R(1,1)*S)*N2 - B*N1;
                    %[C, P] = blsprice(B,K,rT,T,sigma);                    
                    [C, P] = blkprice(B,K,rT,T,sigma);

                case "Brownian"
                    % TODO: LAGA VILLUNA HÉR 
                    alpha = model.longTermMeanLevel;
%                     PtT = exp(-rT*T-(1/2) * alpha * T^2 + (1/6) * sigma^2 * T^3);
%                     PtS = exp(-rT*S-(1/2) * alpha * S^2 + (1/6) * sigma^2 * S^3);
                    
%                     d1 = (log(PtS/(K*PtT))+(1/2)*sigma^2*((S-T)^2)*T)/(sigma*(S-T)*sqrt(T));
%                     d2 = d1 - sigma*(S-T)*sqrt(T);
%N1 = 0.5*(1+erf(d1/sqrt(2)));
                    %N2 = 0.5*(1+erf(d2/sqrt(2)));

                       %C = B*N1 - K*exp(-R(1,1)*S)*N2;
                 
                    PtT = exp( -rT * T - (1/2) * alpha * T^2 + (1/6) * sigma^2 * T^3);
                    d1 = log(B/K + (sigma^2)*(T/2))/(sigma*sqrt(T));
                    d2 = log(B/K - (sigma^2)*(T/2))/(sigma*sqrt(T));

                    
                    N1 = normcdf(d1);
                    N2 = normcdf(d2);
                    C = PtT*(B*N1-K*N2);
                    % Put
                    N1 = normcdf(-d1);
                    N2 = normcdf(-d2);
                    %N1 = 0.5*(1+erf(-d1/sqrt(2)));
                    %N2 = 0.5*(1+erf(-d2/sqrt(2)));
                    %P = K*exp(-R(1,1)*S)*N2 - B*N1;
                    P = PtT*(K*N2-B*N1);
                    
                    %Vasicek KOMID
                case "Vasicek"
                    Q = 1; % Principal of the bond
                    kappa = model.speedOfReversion;
                    theta = model.longTermMeanLevel;

                    BtT = (1/kappa)*(1-exp(-kappa*T));
                    BtS = (1/kappa)*(1-exp(-kappa*S));
                    AtT = exp( (((kappa^2)*theta-(sigma^2)/2)/(kappa^2))*(BtT-T) - ((sigma^2)/(4*kappa))*(BtT^2));
                    AtS = exp( (((kappa^2)*theta-(sigma^2)/2)/(kappa^2))*(BtS-S) - ((sigma^2)/(4*kappa))*(BtS^2));
                    rt = R(1,1);

                    PtT = AtT *exp(-rt*BtT);
                    PtS = AtS *exp(-rt*BtS);

                    sigmaP = (sigma/kappa)*(1-exp( -kappa*(S-T)) ) * sqrt( (1-exp(-2*kappa*T)) /(2*kappa));
                    d = (1/sigmaP)*log( (Q*PtS)/(K*PtT) ) + sigmaP/2;

                    N = @(x) normcdf(x);
                    

                    C = Q * PtS * N(d) - K * PtT * N(d-sigmaP);
                    P = K * PtT * N(-d+sigmaP) - Q * PtS * N(-d);            
            end
        end
        
        function [meanTheta, meanKappa, meanSigma, errorValue] = ordinaryLeastSquaresIterative(obj, n)
            % ESTIMATING THE PARATMETERS OF THE VASICEK MODEL WITH ORDINARY LEAST 
            % SQUARES METHOD 
            % 
            % Returns the average theta, kappa and sigma values and the
            % error value.
            % 
            % E = (avgTheta-theta)^2+(avgKappa-kappa)^2+(avgSigma-sigma)^2  
            
            if obj.model == "Vasicek"
                obj.data;
                trueTheta = obj.longTermMeanLevel;
                trueKappa = obj.speedOfReversion;
                trueSigma = obj.volatility;

                for i = 1:10
                    [theta(i), kappa(i), sigma(i)] = OLS_OU(obj.data(randi(obj.nrOfSimulations),1:n),obj.stepSize);
                end

                meanTheta = mean(theta);
                meanKappa = mean(kappa);
                meanSigma = mean(real(sigma));
                errorValue = (trueTheta-meanTheta)^2+(trueKappa-meanKappa)^2+(trueSigma-meanSigma)^2;
                end
        end
        
        function capsAndFloor(obj)
            % TODO: Þetta
            dt = obj.interestRateModel.stepSize;
            T = obj.optionMaturity;     %Time2mat
            Tk = 0:dt:T;                %Time vec

            Fk = [0.04, 0.039, 0.041];  %Forward rate = HJALP GODI MADUR
            Fk = obj.interestRateModel.forwardRate
            D = [1, 0.95, 0.9];         %discount rate
            
            %R = obj.interestRateModel.data; Spurning um ad nota tetta
            %fyrir LIBOR
            LC = 0.05;                  %Libor rate
            
            for i = 1:1:T/dt
                dL = LC
                LC(i) = dL;
            end
            
            LC = [initial LC]
                
            Q = 1;                      %Pricipal BITCH TITS
            alpha = 0.5;                %Time period
            
            sigma = obj.interestRateModel.volatility;
            
            d1 = (log(Fk/LC) + 0.5*tk*sigma^2)\(sigma*sqrt(tk));
            d2 = d1-sigma*sqrt(tk);
            
            caplet = alpha*Q*D*(Fk*normcdf(d1)-LC*normcdf(d2));
            floorlet = alpha*Q*D*(LC*normcdf(-d2)-Fk*normcdf(-d1));
            
            plot(caplet)
            hold on 
            plot(floorlet)
        end
            
    end
end

