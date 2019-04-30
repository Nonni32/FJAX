classdef portfolio
    % PORTFOLIO
    properties
        ticker = [];
        issue = [];
        maturity = [];
        coupon = [];
        duration = [];
        ask = [];
        bid = [];
        lastPrice = [];
        lastYield = [];
        yield = [];
        interest = [];
        
    end
    
    methods
        function obj = portfolio(bond)
            obj.ticker = string(bond.ticker);
            obj.duration = double(bond.duration);
            obj.issue = string(bond.issue);
            obj.maturity = string(bond.maturity);
            obj.ask = bond.ask;
            obj.bid = bond.bid;
            obj.lastPrice = bond.lastPrice;
            obj.lastYield = bond.lastYield;
            obj.yield = bond.yield;
            obj.coupon = string(bond.coupon);
            obj.interest = bond.interest;
        end
       
        function obj = addToPortfolio(obj, bond)
            obj.ticker = horzcat(obj.ticker, string(bond.ticker));
            obj.duration = horzcat(obj.duration, bond.duration);
            obj.issue = horzcat(obj.issue, string(bond.issue));
            obj.maturity = horzcat(obj.maturity, bond.maturity);
            obj.ask = horzcat(obj.ask, bond.ask);
            obj.bid = horzcat(obj.bid, bond.bid);
            obj.lastPrice = horzcat(obj.lastPrice, bond.lastPrice);
            obj.lastYield = horzcat(obj.lastYield, bond.lastYield);
            obj.yield = horzcat(obj.yield, bond.yield);
            obj.coupon = horzcat(obj.coupon, string(bond.coupon));
            obj.interest = horzcat(obj.interest, bond.interest);
        end
        
        function yieldCurve(obj)   
            % TODO: LAGA ÞETTA - TEIKNA BARA BOND SEM BYRJA Á "RIK"
%             x = []; y = [];
%             for i = 1:length(obj.ticker)
%                 if(obj.ticker{i}(1:3) == 'RIK')
%                     x(i) = datenum(obj.maturity(i),'dd/mm/yyyy');
%                     y(i) = obj.yield(i);
%                 end
%             end
%             plot(x,y)

            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield,'b');
            hold on
            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield,'bo');
            labels = reshape(sprintf('%5.1f%%',obj.yield*100),6,[]).';
            set(gca,'yticklabel',labels)
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
            
        end
        
        function yieldCurveMethod2(obj)
           % TODO
        end
        
    end
end

