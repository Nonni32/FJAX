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
        curveDates
        zeroRates
        forwardRates
        discountRates
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
            % TODO: LAGA ÞETTA - TEIKNA BARA BOND SEM BYRJA Á "RIK"
            
%             x = []; y = [];
%             p = 1;
%             for i = 1:length(obj.ticker)
%                 if(obj.ticker{i}(1:3) == 'RIK')
%                     x(i) = datenum(obj.maturity(i),'dd/mm/yyyy')
%                     y(i) = obj.yield(i)
%                     p = p + 1;
%                     % Þarf að sorta eða kanna afhverju 3 stak er með lengra
%                     % maturity en það 4 og afhverju 4 er með það styðsta
%                 end
%             end
%             plot(x,y)

            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield,'b');
            hold on
            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield,'bo');
            % x-axis date, y-axis percentage
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
            ytickformat('percentage')
        end
        
        % Í CURVES þARF AÐ LAGA XLIM MAX
        function zeroCurve(obj)
           % TODO: Fjalla um
           % https://se.mathworks.com/help/finance/zbtprice.html í skýrslu
           Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)];
           Prices = obj.price;
           Settle = today();
           [zeroRates, curveDates] = zbtprice(Bonds, Prices, Settle);
           plot(curveDates, zeroRates*100,'b')
           % x-axis date, y-axis percentage
           datetick('x','dd/mm/yyyy')
           ytickformat('%.2f%%')
           xlim([min(curveDates) max(curveDates)]);
           obj.curveDates = curveDates';
           obj.zeroRates = zeroRates';
        end        
        
        function forwardCurve(obj)
            Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)];
            Prices = obj.price;
            Settle = today();
            [zeroRates, curveDates] = zbtprice(Bonds, Prices, Settle);
            [forwardRates, curveDates] = zero2fwd(zeroRates, curveDates, Settle);
            plot(curveDates,forwardRates*100)
            % x-axis date, y-axis percentage
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(curveDates) max(curveDates)]);
            obj.curveDates = curveDates';
            obj.zeroRates = zeroRates';
            obj.forwardRates = zeroRates';
        end        
        
        function discountCurve(obj)
            Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)];
            Prices = obj.price;
            Settle = today();
            [zeroRates, curveDates] = zbtprice(Bonds, Prices, Settle);
            [forwardRates, curveDates] = zero2fwd(zeroRates, curveDates, Settle);
            [discRates, curveDates] = zero2disc(zeroRates, curveDates, Settle);
            plot(curveDates,discRates*100)
            % x-axis date, y-axis percentage
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(curveDates) max(curveDates)]);
            obj.curveDates = curveDates';
            obj.zeroRates = zeroRates';
            obj.forwardRates = forwardRates';
            obj.discountRates = discRates';
        end
        
        function fitMethod(curve, method)
            % Slá inn hvaða curve og síðan hvaða method
            % Curves = {"yield", "zero", "forward", "discount"}
            % Hafa nokkur methods í boði? 
            dates = obj.curveDates;
            if curve == "yield"
                rates = obj.yield;
            elseif curve == "zero"
                rates = obj.zeroRates;
            elseif curve == "forward"
                rates = obj.forwardRates;
            elseif curve == "discount"
                rates = obj.discountRates;
            end
            
            % TODO: Klára methods, finna öll föll og blablabla
            0
            
        end
    end
end

