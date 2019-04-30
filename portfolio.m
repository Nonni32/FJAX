classdef portfolio
    % PORTFOLIO
    properties
        ticker = [];
        issue = [];
        maturity = [];
        coupon = [];
        frequency = [];
        duration = [];
        ask = [];
        bid = [];
        price = [];
        lastPrice = [];
        lastYield = [];
        yield = [];
        interest = [];
        curveDates = [];
        zeroRates = [];
        forwardRates = [];
        discRates = [];
    end
    
    methods
        function obj = portfolio(bond)
            obj.ticker = string(bond.ticker);
            obj.duration = double(bond.duration);
            obj.issue = string(bond.issue);
            obj.maturity = string(bond.maturity);
            obj.ask = bond.ask;
            obj.bid = bond.bid;
            obj.price = bond.price;
            obj.lastPrice = bond.lastPrice;
            obj.lastYield = bond.lastYield;
            obj.yield = bond.yield;
            obj.coupon = string(bond.coupon);
            if(string(bond.coupon) == "Semiannual")
                obj.frequency = 2;
            else
                obj.frequency = 1;
            end
            obj.interest = bond.interest;
            
        end
       
        function obj = addToPortfolio(obj, bond)
            obj.ticker = horzcat(obj.ticker, string(bond.ticker));
            obj.duration = horzcat(obj.duration, bond.duration);
            obj.issue = horzcat(obj.issue, string(bond.issue));
            obj.maturity = horzcat(obj.maturity, bond.maturity);
            obj.ask = horzcat(obj.ask, bond.ask);
            obj.bid = horzcat(obj.bid, bond.bid);
            obj.price = horzcat(obj.price, bond.price);
            obj.lastPrice = horzcat(obj.lastPrice, bond.lastPrice);
            obj.lastYield = horzcat(obj.lastYield, bond.lastYield);
            obj.yield = horzcat(obj.yield, bond.yield);
            obj.coupon = horzcat(obj.coupon, string(bond.coupon));
            if(string(bond.coupon) == "Semiannual")
                obj.frequency = horzcat(obj.frequency, 2);
            else
                obj.frequency = horzcat(obj.frequency, 1);
            end
            obj.interest = horzcat(obj.interest, bond.interest);
        end
        
        function yieldCurve(obj)   
            % TODO: LAGA �ETTA - TEIKNA BARA BOND SEM BYRJA � "RIK"
            
%             x = []; y = [];
%             p = 1;
%             for i = 1:length(obj.ticker)
%                 if(obj.ticker{i}(1:3) == 'RIK')
%                     x(i) = datenum(obj.maturity(i),'dd/mm/yyyy')
%                     y(i) = obj.yield(i)
%                     p = p + 1;
%                     % �arf a� sorta e�a kanna afhverju 3 stak er me� lengra
%                     % maturity en �a� 4 og afhverju 4 er me� �a� sty�sta
%                 end
%             end
%             plot(x,y)

            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield,'b');
            hold on
            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield,'bo');
            
            % x-axis date, y-axis percentage
            labels = reshape(sprintf('%5.1f%%',obj.yield*100),6,[]).';
            set(gca,'yticklabel',labels)
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
        end
        
        % � CURVES �ARF A� LAGA XLIM MAX
        function obj = zeroCurve(obj)
           % TODO: Fjalla um
           % https://se.mathworks.com/help/finance/zbtprice.html � sk�rslu
           Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)]
           Prices = obj.price;
           Settle = today();
           [obj.zeroRates, obj.curveDates] = zbtprice(Bonds, Prices, Settle)
           plot(obj.curveDates,obj.zeroRates)
           % x-axis date, y-axis percentage
           labels = reshape(sprintf('%5.1f%%',obj.zeroRates*100),6,[]).';
           set(gca,'yticklabel',labels)
           datetick('x','dd/mm/yyyy')
           xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
        end        
        
        function obj = forwardCurve(obj)
            Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)]
            Prices = obj.price;
            Settle = today();
            [obj.zeroRates, obj.curveDates] = zbtprice(Bonds, Prices, Settle);
            [obj.forwardRates, obj.curveDates] = zero2fwd(obj.zeroRates, obj.curveDates, Settle);
            plot(obj.curveDates,obj.forwardRates)
            % x-axis date, y-axis percentage
            labels = reshape(sprintf('%5.1f%%',obj.forwardRates*100),6,[]).';
            set(gca,'yticklabel',labels)
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
        end        
        
        function obj = discountCurve(obj)
            Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)]
            Prices = obj.price;
            Settle = today();
            [obj.zeroRates, obj.curveDates] = zbtprice(Bonds, Prices, Settle);
            [obj.forwardRates, obj.curveDates] = zero2fwd(obj.zeroRates, obj.curveDates, Settle);
            [obj.discRates, obj.curveDates] = zero2disc(obj.zeroRates, obj.curveDates, Settle);
            plot(obj.curveDates,obj.discRates)
            % x-axis date, y-axis percentage
            labels = reshape(sprintf('%5.1f%%',obj.discRates*100),6,[]).';
            set(gca,'yticklabel',labels)
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
            % x-axis date, y-axis percentage
            labels = reshape(sprintf('%5.1f%%',obj.zeroRates*100),6,[]).';
            set(gca,'yticklabel',labels)
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
        end        
    end
end

