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
        couponRate % TODO
        compounding % TODO 
        startDate
        settleDate
        endDate
        payCurve
        receiveCurve
        basisPoints % 1x2 array
        price
        swapRate
        AI % Accrued interest
        payCF
        payDates
        receiveCF
        receiveDates
    end
    
    methods
        function obj = swap(payPortfolio, receivePortfolio, pay, receive, payments, principal, startDate, settleDate, endDate, payCurve, receiveCurve, basisPoints)
            % Initialise swap object
            obj.payPortfolio = payPortfolio;
            obj.receivePortfolio = receivePortfolio;
            obj.pay = pay;
            obj.receive = receive;
            obj.payments = payments;
            obj.principal = principal;
            obj.startDate = startDate;
            obj.settleDate = settleDate;
            obj.endDate = endDate;
            obj.payCurve = payCurve;
            obj.receiveCurve = receiveCurve;
            obj.basisPoints = basisPoints;
            obj = obj.valueSwap;
        end
        
        function obj = valueSwap(obj)
            alpha = obj.payments.^(-1)
            obj.payments
            Settle = datenum(obj.settleDate);
            endDatesPay = {};
            endDatesReceive = {};
            
            datesPay = datenum(obj.payPortfolio.maturity,'dd/mm/yyyy');
            payDates = datenum(obj.startDate)+1:round(365/obj.payments(1)):max(datesPay);
            size(payDates)
            y = obj.payCurve/100;
            ratePay = y(payDates-datenum(obj.startDate)+1);
            
            for i = 1:length(ratePay)
                endDatesPay{i} = datestr(payDates(i),'dd-mmm-yyyy');
            end
            
            datesReceive = datenum(obj.payPortfolio.maturity,'dd/mm/yyyy');
            receiveDates = datenum(obj.startDate)+1:round(365/obj.payments(2)):max(datesReceive);
            yy = obj.receiveCurve/100;
            rateReceive = yy(receiveDates-datenum(obj.startDate)+1)
            
            for i = 1:length(rateReceive)
                endDatesReceive{i} = datestr(receiveDates(i),'dd-mmm-yyyy');
            end
            
            RateSpecPay = intenvset('Rates', ratePay','StartDates',Settle, 'EndDates', endDatesPay')
            RateSpecReceive = intenvset('Rates', rateReceive','StartDates',Settle, 'EndDates',endDatesReceive')
            
            Maturity = datenum(obj.endDate)
            Spread = obj.basisPoints

            LegType = [obj.pay obj.receive];
            
            LegRate = [0.05 Spread(1)]; % TODO LAGA ÞETTA SKÍTAMIX
            
            if sum(LegType) == 1
                if(LegType(1) == 0)
                    [obj.price, obj.swapRate, obj.AI, obj.receiveCF, obj.receiveDates, obj.payCF, obj.payDates] = ...
                        swapbyzero(RateSpecPay, LegRate, Settle, Maturity,'LegType',LegType,...
                        'AdjustCashFlowsBasis',true,...
                        'BusinessDayConvention','modifiedfollow')         
                elseif LegType(2) == 0
                    [obj.price, obj.swapRate, obj.AI, obj.receiveCF, obj.receiveDates, obj.payCF, obj.payDates] = ...
                        swapbyzero(RateSpecPay, LegRate, Settle, Maturity,'LegType',LegType,...
                        'AdjustCashFlowsBasis',true,...
                        'BusinessDayConvention','modifiedfollow')    
                end
            elseif (sum(LegType) == 0)
%                 Rates = [ratePay' rateReceive'];
%                 Settle = [Settle Settle];
%                     
%                 RateSpecPay = intenvset('Rates', ratePay','StartDates',Settle, 'EndDates', endDatesPay')
%                 RateSpecReceive = intenvset('Rates', rateReceive','StartDates',Settle, 'EndDates',endDatesReceive')
                RateSpec = [RateSpecPay RateSpecReceive];
                [obj.price, ~ ,obj.AI,obj.receiveCF, obj.receiveDates, obj.payCF, obj.payDates] = swapbyzero(RateSpec, LegRate, Settle, Maturity, 'Principal', obj.principal);
            end
        end
        
        function plotCashFlow(obj)
           grid on
           bar(obj.receiveCF)
           hold on
           bar(-obj.payCF)
           hold off
           datetick('x','dd/mm/yyyy')
%            xlim([min(min(obj.payDates),min(obj.receiveDates)) max(max(obj.payDates),max(obj.receiveDates))])
        end
    end
end

