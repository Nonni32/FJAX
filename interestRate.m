classdef interestRate
    % INTEREST RATE
    properties
        model
        initialRate
        stepSize
        volatility
        alpha
        speedOfReversion
        longTermMeanLevel
        optionMaturity
        maturity
        nrOfSimulations
        nbins
        data
        rateAtMaturity
        dates
    end
    
    methods
        function obj = interestRate(model, initialRate, stepSize, volatility, alpha, speedOfReversion, longTermMeanLevel, maturity, nrOfSimulations)
            % Initialise interest rate model
            obj.model = model;
            obj.initialRate = initialRate;
            obj.stepSize = stepSize;
            obj.volatility = volatility;
            obj.alpha = alpha;
            obj.speedOfReversion = speedOfReversion;
            obj.longTermMeanLevel = longTermMeanLevel;
            obj.maturity = maturity;
            obj.nrOfSimulations = nrOfSimulations;
            N = obj.maturity/obj.stepSize;
            obj.nbins = 100;
            obj.data = zeros(obj.nrOfSimulations, N);
            obj.rateAtMaturity = zeros(1, obj.nrOfSimulations);
            obj.dates = zeros(N,1);
            for i = 1:N
                obj.dates(i) = today+i-1;
            end
            obj = obj.simulateModel;
        end
        
        function obj = simulateModel(obj)
            % Simulations
            L = obj.nrOfSimulations;
            N = obj.maturity/obj.stepSize;
            W = randn(L,N)*sqrt(obj.stepSize);
            switch obj.model
                case "Simple"
                    for i = 1:L
                        obj.data(i,1) = obj.initialRate;
                        for j = 2:N
                            dR = obj.volatility*W(i,j);
                            obj.data(i,j) = obj.data(i,j-1)+dR;
                        end
                        obj.rateAtMaturity(i) = obj.data(i,N);
                    end
                case "Brownian"
                    a = obj.alpha;
                    for i = 1:L
                        obj.data(i,1) = obj.initialRate;
                        for j = 2:N
                            dR = a*obj.stepSize+obj.volatility*W(i,j);
                            obj.data(i,j) = obj.data(i,j-1)+dR;
                        end
                        obj.rateAtMaturity(i) = obj.data(i,N);
                    end    
                case "Vasicek"
                    r0 = obj.initialRate;
                    kappa = obj.speedOfReversion;
                    theta = obj.longTermMeanLevel;
                    sigma = obj.volatility;
                    dt = obj.stepSize;
                    N = obj.maturity/dt;
                    obj.nrOfSimulations;
                    
                    for i = 1:obj.nrOfSimulations
                        [obj.data(i,:)] = OrnsteinUhlenbeckSDE(r0, kappa, theta, sigma, dt, N);
                        obj.rateAtMaturity(i) = obj.data(i,end);
                    end
            end
        end
        
        function histModel(obj)
            if obj.model == "Simple"
                histfit(obj.rateAtMaturity*100,100,'normal')
            elseif obj.model == "Brownian"
                histfit(obj.rateAtMaturity*100 ,100,'normal')
            elseif obj.model == "Vasicek"
                histfit(obj.rateAtMaturity*100 ,100,'normal')
            end
            xtickformat('%.2f%%')

        end
        
        function plotSimulations(obj)
            N = obj.maturity/obj.stepSize;
            grid on
            for i = 1:obj.nrOfSimulations
                plot(obj.dates,obj.data(i,:)*100) 
                hold on
            end
            plot([min(obj.dates) max(obj.dates)],[0 0],'k')
            datetick('x','dd/mm/yyyy')
            ytickformat('%.2f%%')
            xlim([min(obj.dates) max(obj.dates)]);
        end
        
        function [meanTheta, meanKappa, meanSigma] = estimateParameters(obj)
            if obj.model == "Vasicek"
                theta = obj.longTermMeanLevel;
                kappa = obj.speedOfReversion;
                sigma = obj.volatility;
                for i = 1:obj.nrOfSimulations
                    [est_theta(i), est_kappa(i), est_sigma(i)] = MLE_OU(obj.data(i,:),obj.stepSize);
                end
                meanTheta = mean(est_theta);
                meanKappa = mean(est_kappa);
                meanSigma = mean(est_sigma);
%                 fprintf('Theta: %.4f vs %.4f\n',theta, meanTheta);
%                 fprintf('Kappa: %.4f vs %.4f\n',kappa, meanKappa);
%                 fprintf('Sigma: %.4f vs %.4f\n',sigma, meanSigma);
            end 
        end
        
        function [meanTheta, meanKappa, meanSigma] = estimateParametersIterative(obj, N)
            if obj.model == "Vasicek"
                for i = 1:obj.nrOfSimulations
                    [est_theta(i), est_kappa(i), est_sigma(i)] = MLE_OU(obj.data(i,2:N),obj.stepSize);
                end
                meanTheta = mean(est_theta);
                meanKappa = mean(est_kappa);
                meanSigma = mean(est_sigma);
            end 
        end
    end
end


function [y] = OrnsteinUhlenbeckSDE(x0,la,mu,sigma,dt,NoOfIt)

    %Sverrir Olafsson, 01-March-2019

    %This function simulates the mean reverting Ornstein-Uhlenbeck SDE NoOfIt
    %iterations

    x  = x0;  %initialisation
    r  = randn(1,NoOfIt);
     for i = 1:NoOfIt                                 %Number of iterations      
         dx = la*(mu - x)*dt + sigma*sqrt(dt)*r(i);   %increment in Ornstein-Uhlenbeck process
         x = x + dx;                                  %Ornstein-Uhlenbeck process
         y(i)= x;                                     %Ornstein-Uhlenbeck process  
     end                                              %Number of iterations

    T   = 1:1:NoOfIt;
    ry  = [x0 y];
    rr  = [0 r];
    rT  = 0:1:NoOfIt;

    rOP = [rT' (rT*dt)' ry' rr'];  

    %Sx  = sum(ry(1:NoOfIt));
    %Sy  = sum(ry(2:NoOfIt+1));

    for i=1:NoOfIt
        TSx(i)  = ry(i);
        TSy(i)  = ry(i+1);
        TSxx(i) = ry(i)^2;
        TSxy(i) = ry(i)*ry(i+1);
        TSyy(i) = ry(i+1)^2;
    end
    Sx  = sum(TSx);
    Sy  = sum(TSy);
    Sxx = sum(TSxx);
    Sxy = sum(TSxy);
    Syy = sum(TSyy);
    est_mu = (Sy*Sxx - Sx*Sxy)/( NoOfIt*(Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
    est_la = -(1/dt)*log(    ( Sxy - est_mu*Sx - est_mu*Sy + NoOfIt*est_mu^2 )/(  Sxx - 2*est_mu*Sx + NoOfIt*est_mu^2 )  );
    al = exp(-est_la*dt);
    sig_sq = (1/NoOfIt)*( Syy - 2*al*Sxy + al^2*Sxx - 2*est_mu*(1 - al)*(Sy - al*Sx) + NoOfIt*est_mu^2*(1 - al)^2);
    %est_sigma_sq = sig_sq*(2*est_la/(1 - al^2));
    est_sigma = sqrt(sig_sq*2*est_la/(1 - al^2));
    est_la;
    est_mu;
    est_sigma;
    %[la est_la;mu est_mu;sigma est_sigma]
end

function [est_theta, est_kappa, est_sigma] = MLE_OU(ds, dt)
    %Parameter estimation based on assumed Ornstein-Uhlenbeck dynamics
    ry = ds;
    NoOfIt = length(ry);
    for i=1:NoOfIt-1
        TSx(i) = ry(i);
        TSy(i)  = ry(i+1);
        TSxx(i) = ry(i)^2;
        TSxy(i) = ry(i)*ry(i+1);
        TSyy(i) = ry(i+1)^2;
    end
    Sx  = sum(TSx);
    Sy  = sum(TSy);
    Sxx = sum(TSxx);
    Sxy = sum(TSxy);
    Syy = sum(TSyy);
    est_theta = (Sy*Sxx - Sx*Sxy)/( NoOfIt*(Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
    est_kappa = -(1/dt)*log(( Sxy - est_theta*Sx - est_theta*Sy + NoOfIt*est_theta^2 )/(Sxx - 2*est_theta*Sx + NoOfIt*est_theta^2));
    al = exp(-est_kappa*dt);
    sig_sq = (1/NoOfIt)*( Syy - 2*al*Sxy + al^2*Sxx - 2*est_theta*(1 - al)*(Sy - al*Sx) + NoOfIt*est_theta^2*(1 - al)^2);
    est_sigma = sqrt(sig_sq*2*est_kappa/(1 - al^2));
end
