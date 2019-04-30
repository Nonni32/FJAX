classdef portfolio
    % PORTFOLIO
    properties
        ticker = [];
        duration = [];
        ask = [];
        bid = [];
        lastPrice = []; 
        lastYield = [];
        yield = [];
        coupon = [];
        interest = [];
    end
    
    methods
        function obj = portfolio(bond)
            obj.ticker = string(bond.ticker);
            obj.duration = bond.duration;
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
            obj.ask = horzcat(obj.ask, bond.ask);
            obj.bid = horzcat(obj.bid, bond.bid);
            obj.lastPrice = horzcat(obj.lastPrice, bond.lastPrice);
            obj.lastYield = horzcat(obj.lastYield, bond.lastYield);
            obj.yield = horzcat(obj.yield, bond.yield);
            obj.coupon = horzcat(obj.coupon, string(bond.coupon));
            obj.interest = horzcat(obj.interest, bond.interest);
        end
        
        function yieldCurveMethod1(obj)
           % TODO
           x = 0:10;
           y = 0:10;
           plot(x,y)
        end
        
        
        function yieldCurveMethod2(obj)
           % TODO
        end
    end
end

