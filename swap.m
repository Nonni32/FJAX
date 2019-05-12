classdef swap
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        payPortfolio
        receivePortfolio
        pay 
        receive
        payments % per year 1x2 array 
        principal
        couponRate
        startDate
        settleDate
        endDate
        payCurve
        receiveCurve
        basisPoints % 1x2 array
        
        % B�TA VI� PROPERTIES FYRIR 
        % [Price, SwapRate, AI, RecCF, RecCFDates, PayCF,PayCFDates] = ...
        % + �A� SEM �ARF � ��RUM F�LLUM 
            
    end
    
    methods
        function obj = swap(payPortfolio, receivePortfolio, pay, receive, payments, principal, startDate, settleDate, endDate, payCurve, receiveCurve, basisPoints)
            % Initialise swap object
            obj.payPortfolio;
            obj.receivePortfolio;
            obj.pay = pay;
            obj.receive = receive;
            obj.payments = payments;
            obj.principal = principal;
            obj.couponRate = 0.05;
            obj.startDate = startDate;
            obj.settleDate = settleDate;
            obj.endDate = endDate;
            obj.payCurve = payCurve;
            obj.receiveCurve = receiveCurve;
            obj.basisPoints = basisPoints;
            
            % SPLITTA � NOKKUR FUNCTION 
            
            if(datenum(startDate) == datenum(settleDate))
                obj = obj.valueSpotSwap;
            else
                obj = obj.valueForwardSwap;
            end
        end
        
        function obj = valueSwap(obj)
            % TODO: Evaluate swap
            alpha = obj.payments.^(-1);
            Settle = datenum(obj.settleDate);Ni
            
            datesPay = datenum(payPortfolio.maturity,'dd/mm/yyyy');
            xPay = linspace(today,max(datesPay),max(datesPay)-today);
            endDatePay = today:round(365/2):max(datesPay);
            ratePay = y(endDatePay-today+1);
            
            datesReceive = datenum(payPortfolio.maturity,'dd/mm/yyyy');
            xReceive = linspace(today,max(datesReceive),max(datesReceive)-today);
            endDateReceive = today:round(365/2):max(datesReceive);
            rateReceive = y(endDateReceive-today+1);
            
            RateSpecPay = intenvset('Rates', ratePay,'StartDates',Settle, 'EndDates',endDatesReceive);
            RateSpecReceive = intenvset('Rates', rateReceive,'StartDates',Settle, 'EndDates',endDatePay);
            
            Maturity = datenum(obj.endDate); 
            Spread = obj.basisPoints;
            
            LegRate = [obj.couponRate spread];
            LegType = [obj.pay obj.receive];
            
            [Price, SwapRate, AI, RecCF, RecCFDates, PayCF,PayCFDates] = ...
            swapbyzero(RateSpec, LegRate, Settle, Maturity,'LegType',LegType,...
            'AdjustCashFlowsBasis',true,...
            'BusinessDayConvention','modifiedfollow')       %'LatestFloatingRate',LatestFloatingRate,
        end
        
        function obj = valueForwardSwap(obj)
            % TODO: Evaluate swap
        end
    end
end

