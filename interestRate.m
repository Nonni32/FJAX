classdef interestRate
    % INTEREST RATE
    properties
        model
        initialRate
        stepSize
        sigma 
        %optionMaturity
        maturity
        nrOfSimulations
        %nbins = 100;
        %strike
    
    methods
        function obj = interestRate(model, initialRate, stepSize, sigma, maturity, nrOfSimulations)
            % Initialise interest rate model
            obj.model = model;
            obj.initialRate = initialRate;
            obj.stepSize = stepSize;
            obj.sigma = sigma;
            obj.maturity = maturity;
            obj.nrOfSimulations = nrOfSimulations;
            
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

