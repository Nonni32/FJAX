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
        
        function yieldCurveMethod1(obj)
%            % TODO
           x = 0:10;
           y = 0:10;
           plot(x,y)
        end
        
        
        function yieldCurveMethod2(obj)
           % TODO
        end
    end
end

