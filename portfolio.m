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
            obj.ticker = bond.ticker;
            obj.duration = bond.duration;
            obj.ask = bond.ask;
            obj.bid = bond.bid;
            obj.lastPrice = bond.lastPrice;
            obj.lastYield = bond.lastYield;
            obj.yield = bond.yield;
            obj.coupon = bond.coupon;
            obj.interest = bond.interest;
        end
        
        function addToPortfolio(bond)
            obj.ticker(end+1) = bond.ticker;
            obj.duration(end+1) = bond.duration;
            obj.ask(end+1) = bond.ask;
            obj.bid(end+1) = bond.bid;
            obj.lastPrice(end+1) = bond.lastPrice;
            obj.lastYield(end+1) = bond.lastYield;
            obj.yield(end+1) = bond.yield;
            obj.coupon(end+1) = bond.coupon;
            obj.interest(end+1) = bond.interest;
        end
    end
end

