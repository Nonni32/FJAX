classdef interestRate
    % About 
    % Interest rate object, used for simulations in interestRateGUI.m and
    % pricingModel.m. 
    % 
    % INPUT 1: MODEL (STRING) 
    %   MODELS AVAILABLE: SIMPLE, BROWNIAN, VASICEK
    % INPUT 2: INITIAL RATE(DOUBLE) 
    % INPUT 3: STEP SIZE (DOUBLE) - USUALLY 1/250 
    % INPUT 4: VOLATILITY (DOUBLE)
    % INPUT 5: SPEED OF REVERSION (DOUBLE) 
    % INPUT 6: LONG TERM MEAN LEVEL (DOUBLE)
    % INPUT 7: MATURITY (DOUBLE) - NR OF YEARS 
    % INPUT 8: NUMBER OF SIMULATIONS (INTEGER) 
    %
    % Properties accessible:
    % model, initial rate, step size, volatility, speed of reversion, long
    % term mean level, maturity, number of simulations, nbins (histogram),
    % data (simulated interest rates), rates at maturity and dates.
  
    properties
        model
        initialRate
        stepSize
        volatility
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
        function obj = interestRate(model, initialRate, stepSize, volatility, speedOfReversion, longTermMeanLevel, maturity, nrOfSimulations)
            % INITIALISING THE INTEREST RATE MODEL 
            
            obj.model = model;
            obj.initialRate = initialRate;
            obj.stepSize = stepSize;
            obj.volatility = volatility;
            obj.speedOfReversion = speedOfReversion;
            obj.longTermMeanLevel = longTermMeanLevel;
            obj.maturity = maturity;
            obj.nrOfSimulations = nrOfSimulations;
            N = obj.maturity/obj.stepSize;
            obj.nbins = 100;
            % Preallocating the array to save memory and processing power
            obj.data = zeros(obj.nrOfSimulations, N);
            obj.rateAtMaturity = zeros(1, obj.nrOfSimulations);
            obj.dates = linspace(today(), today()+maturity*365, N);
            obj = obj.simulateModel;
        end
        
        function obj = simulateModel(obj)
            % SIMULATING THE INTEREST RATE MODEL
            
            L = obj.nrOfSimulations;
            N = obj.maturity/obj.stepSize;
            W = randn(L,N)*sqrt(obj.stepSize);
            switch obj.model
                case 'Simple'
                    for i = 1:L
                        obj.data(i,1) = obj.initialRate;
                        for j = 2:N
                            dR = obj.volatility*W(i,j);
                            obj.data(i,j) = obj.data(i,j-1)+dR;
                        end
                        obj.rateAtMaturity(i) = obj.data(i,N);
                    end
                case 'Brownian'
                    a = obj.longTermMeanLevel;
                    for i = 1:L
                        obj.data(i,1) = obj.initialRate;
                        for j = 2:N
                            dR = a*obj.stepSize+obj.volatility*W(i,j);
                            obj.data(i,j) = obj.data(i,j-1)+dR;
                        end
                        obj.rateAtMaturity(i) = obj.data(i,N);
                    end    
                case 'Vasicek'
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
           % PLOTTING THE HISTOGRAM FOR THE INTEREST RATE MODEL
           
           histfit(obj.rateAtMaturity*100, 100,'normal')
           grid on
           xtickformat('%.2f%%')
        end
        
        function plotSimulations(obj)
            % PLOTTING THE SIMULATIONS OF THE INTEREST RATES 
            
            N = obj.maturity/obj.stepSize;
            
            for i = 1:obj.nrOfSimulations
                plot(obj.dates,obj.data(i,:)*100) 
                hold on
            end
            plot([min(obj.dates) max(obj.dates)],[0 0],'k','HandleVisibility','off')
            datetick('x','dd/mm/yyyy')
            ytickformat('%.2f%%')
            xlim([min(obj.dates) max(obj.dates)]);
            grid on
        end
        
        function [meanTheta, meanKappa, meanSigma, errorValue] = estimateParameters(obj)
            % ESTIMATING THE PARATMETERS OF THE VASICEK MODEL WITH MAXIMUM
            % LIKELIHOOD ESTIMATION
            % 
            % Returns the average theta, kappa and sigma values and the
            % error value.
            % 
            % E = (avgTheta-theta)^2+(avgKappa-kappa)^2+(avgSigma-sigma)^2
            
            if obj.model == 'Vasicek'
                theta = obj.longTermMeanLevel;
                kappa = obj.speedOfReversion;
                sigma = obj.volatility;
                for i = 1:obj.nrOfSimulations
                    [est_theta(i), est_kappa(i), est_sigma(i)] = MLE_OU(obj.data(i,:),obj.stepSize);
                end
                meanTheta = mean(est_theta);
                meanKappa = mean(est_kappa);
                meanSigma = mean(est_sigma);
                errorValue = (theta-meanTheta)^2+(kappa-meanKappa)^2+(sigma-meanSigma)^2;
            end 
        end
        
        function [meanTheta, meanKappa, meanSigma, errorValue] = estimateParametersIterative(obj, N)
            % ESTIMATING THE PARATMETERS OF THE VASICEK MODEL WITH MAXIMUM
            % LIKELIHOOD ESTIMATION FOR A GIVEN NUMBER OF ITERATIONS N
            % 
            % Returns the average theta, kappa and sigma values and the
            % error value.
            % 
            % E = (avgTheta-theta)^2+(avgKappa-kappa)^2+(avgSigma-sigma)^2
            
            if obj.model == 'Vasicek'
                theta = obj.longTermMeanLevel;
                kappa = obj.speedOfReversion;
                sigma = obj.volatility;
                for i = 1:10
                    [est_theta(i), est_kappa(i), est_sigma(i)] = MLE_OU(obj.data(randi(obj.nrOfSimulations),2:N),obj.stepSize);
                end
                meanTheta = mean(est_theta);
                meanKappa = mean(est_kappa);
                meanSigma = mean(est_sigma);
                errorValue = (theta-meanTheta)^2+(kappa-meanKappa)^2+(sigma-meanSigma)^2;
            end 
        end
        
        function obj = estimationImprovement(obj)
            % SHOWS HOW THE ESTIMATION IMPROVES WITH THE NUMBER OF
            % ITERATIONS USING THE MAXIMUM LIKELIHOOD ESTIMATION 
            
            N = obj.maturity*250;
            trueTheta = obj.longTermMeanLevel;
            trueKappa = obj.speedOfReversion;
            trueSigma = obj.volatility;
            c = 0;
            for i = 10:N/100:N
                c = c+1;
                [theta(c) kappa(c) sigma(c) error(c)] = obj.estimateParametersIterative(i);
            end
            
            x = 10:N/100:N;
            figure
            subplot(3,1,1)
            plot(x,kappa*100,'LineWidth',1.5)
            hold on
            plot([min(x) max(x)],[trueKappa*100 trueKappa*100],'k--') 
            ytickformat('%.2f%%')
            title('Kappa estimation (' + trueKappa*100 + '%)')
            xlabel('Nr of iterations')
            xlim([min(x) max(x)])
            
            subplot(3,1,2)
            plot(x,theta*100,'LineWidth',1.5)
            hold on
            plot([min(x) max(x)],[trueTheta*100 trueTheta*100],'k--') 
            ytickformat('%.2f%%')
            title('Theta estimation (' + trueTheta*100 + '%)')
            xlabel('Nr of iterations')
            xlim([min(x) max(x)])
            
            subplot(3,1,3)
            plot(x,sigma*100,'LineWidth',1.5)
            hold on
            plot([min(x) max(x)],[trueSigma*100 trueSigma*100],'k--')
            ytickformat('%.2f%%')
            title('Sigma estimation (' + trueSigma*100+ '%)')
            xlabel('Nr of iterations')
            xlim([min(x) max(x)])
            
            sgtitle('Parameter estimation - Maximum likelihood estimation','FontSize',14)
        end
        
        function obj = estimationImprovementOLS(obj)
            % SHOWS HOW THE ESTIMATION IMPROVES WITH THE NUMBER OF
            % ITERATIONS USING ORDINARY LEAST SQUARES
            
            N = obj.maturity*250;
            trueTheta = obj.longTermMeanLevel;
            trueKappa = obj.speedOfReversion;
            trueSigma = obj.volatility;
            c = 0;
            for i = 10:N/100:N
                c = c+1;
                [theta(c) kappa(c) sigma(c) error(c)] = obj.ordinaryLeastSquaresIterative(i);
            end
            
            x = 10:N/100:N;
            figure
            subplot(3,1,1)
            plot(x,kappa*100,'LineWidth',1.5)
            hold on
            plot([min(x) max(x)],[trueKappa*100 trueKappa*100],'k--') 
            ytickformat('%.2f%%')
            title('Kappa estimation (' + trueKappa*100 + '%)')
            xlabel('Nr of iterations')
            xlim([min(x) max(x)])
            
            subplot(3,1,2)
            plot(x,theta*100,'LineWidth',1.5)
            hold on
            plot([min(x) max(x)],[trueTheta*100 trueTheta*100],'k--') 
            ytickformat('%.2f%%')
            title('Theta estimation (' + trueTheta*100 + '%)')
            xlabel('Nr of iterations')
            xlim([min(x) max(x)])
            
            subplot(3,1,3)
            plot(x,sigma*100,'LineWidth',1.5)
            hold on
            plot([min(x) max(x)],[trueSigma*100 trueSigma*100],'k--')
            ytickformat('%.2f%%')
            title('Sigma estimation (' + trueSigma*100+ '%)')
            xlabel('Nr of iterations')
            xlim([min(x) max(x)])
            
            sgtitle('Parameter estimation - Ordinary least squares','FontSize',14)
        end
        
        function [meanTheta, meanKappa, meanSigma, errorValue] = ordinaryLeastSquares(obj)
            % ESTIMATING THE PARATMETERS OF THE VASICEK MODEL WITH ORDINARY LEAST 
            % SQUARES METHOD 
            % 
            % Returns the average theta, kappa and sigma values and the
            % error value.
            % 
            % E = (avgTheta-theta)^2+(avgKappa-kappa)^2+(avgSigma-sigma)^2  
            
            if obj.model == 'Vasicek'
                obj.data;
                trueTheta = obj.longTermMeanLevel;
                trueKappa = obj.speedOfReversion;
                trueSigma = obj.volatility;

                for i = 1:10
                    [theta(i), kappa(i), sigma(i)] = OLS_OU(obj.data(randi(obj.nrOfSimulations),:),obj.stepSize);
                end

                meanTheta = mean(theta);
                meanKappa = mean(kappa);
                meanSigma = mean(real(sigma));
                errorValue = (trueTheta-meanTheta)^2+(trueKappa-meanKappa)^2+(trueSigma-meanSigma)^2;
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
            
            if obj.model == 'Vasicek'
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
    end
end

%% HELPER FUNCTIONS
function [y] = OrnsteinUhlenbeckSDE(x0,la,mu,sigma,dt,N)

    %Sverrir Olafsson, 01-March-2019

    %This function simulates the mean reverting Ornstein-Uhlenbeck SDE NoOfIt
    %iterations

    x  = x0;  %initialisation
    r  = randn(1,N);
     for i = 1:N                                 %Number of iterations      
         dx = la*(mu - x)*dt + sigma*sqrt(dt)*r(i);   %increment in Ornstein-Uhlenbeck process
         x = x + dx;                                  %Ornstein-Uhlenbeck process
         y(i)= x;                                     %Ornstein-Uhlenbeck process  
     end                                              %Number of iterations

    T   = 1:1:N;
    ry  = [x0 y];
    rr  = [0 r];
    rT  = 0:1:N;

    rOP = [rT' (rT*dt)' ry' rr'];  

    %Sx  = sum(ry(1:NoOfIt));
    %Sy  = sum(ry(2:NoOfIt+1));

    for i=1:N
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
    est_mu = (Sy*Sxx - Sx*Sxy)/( N*(Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
    est_la = -(1/dt)*log(    ( Sxy - est_mu*Sx - est_mu*Sy + N*est_mu^2 )/(  Sxx - 2*est_mu*Sx + N*est_mu^2 )  );
    al = exp(-est_la*dt);
    sig_sq = (1/N)*( Syy - 2*al*Sxy + al^2*Sxx - 2*est_mu*(1 - al)*(Sy - al*Sx) + N*est_mu^2*(1 - al)^2);
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

function [theta, kappa, sigma] = OLS_OU(y,dt)
    % Ordinary Least Square for Ornstein-Uhlenbeck
    N = length(y);
    for i = 1:N-1
        TSx(i)  = y(i);
        TSy(i)  = y(i+1);
        TSxx(i) = y(i)^2;
        TSxy(i) = y(i)*y(i+1);
        TSyy(i) = y(i+1)^2;
    end
    
    Sx  = sum(TSx);
    Sy  = sum(TSy);
    Sxx = sum(TSxx);
    Sxy = sum(TSxy);
    Syy = sum(TSyy);
    
    m_est = (N*Sxy - Sx*Sy)/(N*Sxx-Sx^2);
    c_est = (Sy-m_est*Sx)/N;

    sqrtSum = 0;
    for i = 2:N
        sqrtSum = sqrtSum + (y(i)-m_est*y(i-1)-c_est^2);
    end
    sigma_est = sqrt(sqrtSum/(N-2));
    
    kappa = -log(m_est)/dt;
    theta = c_est/(1-m_est);
    sigma = sigma_est*sqrt((2*kappa)/(1-exp(-2*kappa*dt)));
end
