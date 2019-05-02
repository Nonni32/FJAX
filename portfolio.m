classdef portfolio
    % PORTFOLIO
    properties
        % PORTFOLIO PROPERTIES
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
            % INITIALISING THE PORTFOLIO BY ADDING A SINGLE BOND
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
            
            % MOST BONDS ARE CONVENTIONAL COUPONS OR BULLET BONDS
            %   IN SOME CASES THE COUPON PAYMENT IS SEMIN-ANNUAL
            if(string(bond.coupon) == "Semiannual")
                obj.frequency = 2;
            else
                obj.frequency = 1;
            end
            obj.interest = bond.interest;
            
        end
       
        function obj = addToPortfolio(obj, bond)
            % ADDING A BOND TO AN EXISTING PORTFOLIO
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
            
            % MOST BONDS ARE CONVENTIONAL COUPONS OR BULLET BONDS
            %   IN SOME CASES THE COUPON PAYMENT IS SEMIN-ANNUAL
            if(string(bond.coupon) == "Semiannual")
                obj.frequency = horzcat(obj.frequency, 2);
            else
                obj.frequency = horzcat(obj.frequency, 1);
            end
            obj.interest = horzcat(obj.interest, bond.interest);
        end
        
        function yieldCurve(obj)  
            % TODO: LAGA ÞETTA - TEIKNA BARA BOND SEM BYRJA Á "RIK"
            % PLOTTING THE YIELD CURVE AS IT APPEARS ON WWW.BONDS.IS
            plot(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield*100,'bo');
            % x-axis date, y-axis percentage
            grid on
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
            ytickformat('percentage')
        end
        
        function obj = zeroCurve(obj)
           % CALCULATING AND PLOTTING THE ZERO RATE CURVE FROM THE PORTFOLIO
           % TODO: Fjalla um
           % https://se.mathworks.com/help/finance/zbtprice.html í skýrslu
           obj = obj.calculateCurves;
           plot(obj.curveDates, obj.zeroRates*100,'bo')
           % x-axis date, y-axis percentage
           grid on
           datetick('x','dd/mm/yyyy')
           ytickformat('%.2f%%')
           xlim([min(obj.curveDates) max(obj.curveDates)]);
        end        
        
        function obj = forwardCurve(obj)
           % CALCULATING AND PLOTTING THE FORWARD RATE CURVE FROM THE PORTFOLIO
            obj = obj.calculateCurves;
            plot(obj.curveDates,obj.forwardRates*100,'bo')
            % x-axis date, y-axis percentage
            grid on
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(obj.curveDates) max(obj.curveDates)]);
        end        
        
        function obj = discountCurve(obj)
           % CALCULATING AND PLOTTING THE DISCOUNT RATE CURVE FROM THE PORTFOLIO
            obj = obj.calculateCurves;
            plot(obj.curveDates,obj.discountRates*100,'--bo')
            % x-axis date, y-axis percentage
            grid on
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(obj.curveDates) max(obj.curveDates)]);
        end
        
        % function obj = swapCurve(obj)
        %   TODO: SWAP CURVE!
        % end
        
        function obj = calculateCurves(obj)
           % CALCULATING THE RATE CURVES FROM THE PORTFOLIO 
           % (ZERO, FORWARD, DISCOUNT)
            Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)];
            Prices = obj.price;
            Settle = today();
            [zeroRates, curveDates] = zbtprice(Bonds, Prices, Settle);
            [forwardRates, curveDates] = zero2fwd(zeroRates, curveDates, Settle);
            [discRates, curveDates] = zero2disc(zeroRates, curveDates, Settle);
            obj.curveDates = curveDates';
            obj.zeroRates = zeroRates';
            obj.forwardRates = forwardRates';
            obj.discountRates = discRates';
        end
        
        function fitMethod(obj, curve, method)
            % USING A FITTING METHOD TO A CURVE
            %   BOTH THE METHOD AND THE CURVE ARE EXPECTED AS STRING INPUTS
            %   CURVES AVAILABLE: 
            %       "yield", "zero", "forward", "discount", "swap"
            %   METHODS AVAILABLE:
            %       "bootstrapping", "nelson-siegel", "polynomial",
            %       "spline", "cubic spline", "constrained cubic spline"
            %   HUGSANLEGA BÆTA VIÐ
            
            obj = obj.calculateCurves;
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
            
            % TODO: METHODS
            %   - Bootstrapping
            %       - Bootstrapping er í raun það sem ...Curve föllin gera
            %   - Nelson-Siegel
            %   - Polynomials
            %   - Spline
            %       - Biðja um input veldi
            %   - Cubic spline
            %   - Constrained cubic smoothing spline
            %       - Biðja um input smoothing factor [0,1]
            
        end
        
        % KANNSKI BEILA Á ÞETTA - LJÓTUR KÓÐI
        function curve = polynomialFit(obj, x, y, m)
            % POLYNOMIAL FITTING 
            %   Dæmi um notkun
            %   x = 0:10;
            %   y = @(x) 3*x.^2+2*x+19;
            %   a = polyleastsquarefitting(x,y(x),2)
            %   f = @(x) a(1)+a(2).*x+a(3)*x.^2;
            %   plot(x,y(x))
            %   hold on
            %   plot(x,f(x))
            n = size(x,1);
            if n == 1
                n = size(x,2);
            end
            b = zeros(m+1,1);
            for i = 1:n
               for j = 1:m+1
                  b(j) = b(j) + y(i)*x(i)^(j-1);
               end
            end
            p = zeros(2*m+1,1);
            for i = 1:n
               for j = 1:2*m+1
                  p(j) = p(j) + x(i)^(j-1);
               end
            end
            A = zeros(m+1,m+1);
            for i = 1:m+1
               for j = 1:m+1
                  A(i,j) = p(i+j-1);
               end
            end
            curve = A\b;
        end
    end
end

