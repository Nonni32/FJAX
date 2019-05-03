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
        swapRates
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
            obj = obj.calculateCurves;
        end
        
        function yieldCurve(obj)  
            % TODO: LAGA �ETTA - TEIKNA BARA BOND SEM BYRJA � "RIK"
            % PLOTTING THE YIELD CURVE AS IT APPEARS ON WWW.BONDS.IS
            scatter(datenum(obj.maturity,'dd/mm/yyyy'),obj.yield*100,'k','filled');
            % x-axis date, y-axis percentage
            grid on
            datetick('x','dd/mm/yyyy')
            xlim([min(datenum(obj.maturity,'dd/mm/yyyy')) max(datenum(obj.maturity,'dd/mm/yyyy'))]);
            ytickformat('percentage')
        end
        
        function obj = zeroCurve(obj)
           % CALCULATING AND PLOTTING THE ZERO RATE CURVE FROM THE PORTFOLIO
           % TODO: Fjalla um
           % https://se.mathworks.com/help/finance/zbtprice.html � sk�rslu
           obj = obj.calculateCurves;
           scatter(datenum(obj.maturity,'dd/mm/yyyy'),obj.zeroRates*100,'k','filled');
           % x-axis date, y-axis percentage
           grid on
           datetick('x','dd/mm/yyyy')
           ytickformat('%.2f%%')
           xlim([min(obj.curveDates) max(obj.curveDates)]);
        end        
        
        function obj = forwardCurve(obj)
           % CALCULATING AND PLOTTING THE FORWARD RATE CURVE FROM THE PORTFOLIO
            obj = obj.calculateCurves;
           scatter(datenum(obj.maturity,'dd/mm/yyyy'),obj.forwardRates*100,'k','filled');
            % x-axis date, y-axis percentage
            grid on
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(obj.curveDates) max(obj.curveDates)]);
        end        
        
        function obj = discountCurve(obj)
           % CALCULATING AND PLOTTING THE DISCOUNT RATE CURVE FROM THE PORTFOLIO
            obj = obj.calculateCurves;
           scatter(datenum(obj.maturity,'dd/mm/yyyy'),obj.discountRates*100,'k','filled');
            % x-axis date, y-axis percentage
            grid on
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(obj.curveDates) max(obj.curveDates)]);
        end
        
        function obj = swapCurve(obj)
        %   TODO: Fact checka Swap Curve - Lookar fyrir a� vera � lagi
            obj = obj.calculateCurves;

            for i = 1:length(obj.discountRates)
                %Find what coupon frequency is per bond
                if obj.frequency(i) == 2
                    alpha(i) = 0.5; % Alpha is the time period between coupons per bond
                else
                    alpha(i) = 1;
                end
                
                frwRate(i) = obj.forwardRates(i)*100; %Forward rate vector for i time periods
                dcRate(i) = obj.discountRates(i)*100;
                obj.swapRates(i) = (sum(alpha.*dcRate.*frwRate)/sum(alpha.*dcRate))/100; %Calculation of the Swap rate for i time periods
            end
            
            scatter(datenum(obj.maturity,'dd/mm/yyyy'),obj.swapRates*100,'k','filled');
            %Ploting format
            grid on
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(obj.curveDates) max(obj.curveDates)]);
        end
        
        
        function obj = calculateCurves(obj)
           % CALCULATING THE RATE CURVES FROM THE PORTFOLIO 
           % (ZERO, FORWARD, DISCOUNT)
            Bonds = [datenum(obj.maturity) obj.interest' 100*ones(length(obj.ticker),1) obj.frequency' 8*ones(length(obj.ticker),1)];
            Prices = obj.price;
            Settle = today();
            [zeroRates, curveDates] = zbtprice(Bonds, Prices, Settle);
            [forwardRates, curveDates] = zero2fwd(zeroRates, curveDates, Settle);
            [discRates, curveDates] = zero2disc(zeroRates, curveDates, Settle);
            for i = 1:length(obj.discountRates)
                %Find what coupon frequency is per bond
                if obj.frequency(i) == 2
                    alpha(i) = 0.5; % Alpha is the time period between coupons per bond
                else
                    alpha(i) = 1;
                end
                
                frwRate(i) = obj.forwardRates(i)*100; %Forward rate vector for i time periods
                dcRate(i) = obj.discountRates(i)*100;
                obj.swapRates(i) = (sum(alpha.*dcRate.*frwRate)/sum(alpha.*dcRate))/100; %Calculation of the Swap rate for i time periods
            end
            obj.curveDates = curveDates';
            obj.zeroRates = zeroRates';
            obj.forwardRates = forwardRates';
            obj.discountRates = discRates';
        end
        
        function fitMethod(obj, curve, method, polyDegree, smoothingFactor)
            % USING A FITTING METHOD TO A CURVE
            %   BOTH THE METHOD AND THE CURVE ARE EXPECTED AS STRING INPUTS
            %   CURVES AVAILABLE: 
            %       "Yield", "Zero rates", "Forward rates", "Discount rates", "Swap rates"
            %   METHODS AVAILABLE:
            %       "Bootstrapping", "Nelson-Siegel", "Polynomial", "Spline", "Cubic spline", "Constrained cubic spline"
            %   HUGSANLEGA B�TA VI�
            
            obj = obj.calculateCurves;
            dates = datenum(obj.maturity,'dd/mm/yyyy');
            if curve == "Yield"
                rates = obj.yield;
            elseif curve == "Zero rates"
                rates = obj.zeroRates;
            elseif curve == "Forward rates"
                rates = obj.forwardRates;
            elseif curve == "Discount rates"
                rates = obj.discountRates;
            elseif curve == "Swap rates"
                rates = obj.swapRates;
            end
            
            if method == "Bootstrapping"
                hold on
                plot(dates, rates,'--')
            elseif method == "Nelson-Siegel"
                obj.nelsonSiegelFit(dates,rates);
            elseif method == "Polynomial"
                obj.polynomialFit(dates, rates, polyDegree);
            elseif method == "Spline"
                obj.splineFit(dates, rates);
            elseif method == "Cubic spline"
                obj.cubicSplineFit(dates, rates);
            elseif method == "Constrained cubic spline"
                obj.constrainedCubicSplineFit(dates, rates, smoothingFactor);
            end
        end    
        
        % Nelson-Siegel fit by Dimitri Shvorob
        function obj = nelsonSiegelFit(obj, x, y)
            % By Dimitri Shvorob 
            % https://uk.mathworks.com/matlabcentral/fileexchange/18160-evaluate-nelson-siegel-function
            % NELSONFIT Fit Nelson-Siegel function 
            % Inputs    x,y - n*1 or 1*n vectors
            % Outputs   par - structure with fields 'beta' (3*1 vector), 'tau' (scalar)
            % Notes     No non-negativity constraints are imposed on betas; taus are
            %           searched over by FMINBND within range (0,10).
            % Example   x = [.125 .25  .5   1    2    3    5    7    10   20   30]
            %           y = [2.57 3.18 3.45 3.34 3.12 3.13 3.52 3.77 4.11 4.56 4.51]
            %           par = nelsonfit(x,y)
            % Author    Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 12/30/07
            par.tau  = fminbnd(@(tau) nelsonsse(tau),0,10);
            par.beta = lsbetas(par.tau);
           
            NS = nelsonfun(x,par);
            hold on
            plot(x,NS*100,'--')
            
            function[f] = nelsonsse(tau)
                [b,f] = lsbetas(tau);                        
            end
            function[b,varargout] = lsbetas(tau)
                i = x(:)/tau;
                j = 1-exp(-i);
                n = length(x);
                z = [ones(n,1) j./i (j./i)+j-1];
                b = (z'*z)\(z'*y(:)); 
                e = y(:) - z*b;
                varargout(1) = {e'*e};
            end
            
            function[y] = nelsonfun(x,par)
            % NELSONFUN Evaluate Nelson-Siegel function 
            % Inputs    x   - n*1 or 1*n vector
            %           par - structure with fields 'beta' (3*1 or 1*3 vector), 'tau' (scalar)
            % Outputs   y   - n*1 vector
            % Example   par.beta = [.05 .1 .5]
            %           par.tau  = 1
            %           x = [.125 .25 .5 1 2 3 5 7 10 20 30]
            %           y = nelsonfun(x,par)
            % Author    Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 12/30/07
            checkfield('beta',3)
            checkfield('tau' ,1)
            i = x(:)/par.tau;
            j = 1-exp(-i);
            y = par.beta(1) + par.beta(2)*j./i + par.beta(3)*((j./i)+j-1);
            end
            
            function checkfield(name,n)
                if ~isfield(par,name)
                   error('Field "%s" not found in parameter structure',name) 
                else
                   if ~isvector(par.(name)) || numel(par.(name)) ~= n
                      error('Field "%s" must have %d elements',name,n) 
                   end   
                end
            end
        end
        
        
        

        
        function obj = polynomialFit(obj,dates,rates,n)
            hold on
            degree = n;
            ws = warning('off','all');  % Turn off warning
            p = polyfit(dates', rates, degree);
            warning(ws)  % Turn it back on.
            px = linspace(min(dates),max(dates),max(dates)-min(dates));
            py = polyval(p, px);
            plot(px, py*100,'r--')
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(dates) max(dates)])
        end
        
        function obj = splineFit(obj, dates, rates)
            hold on
            xsp = linspace(min(dates),max(dates),max(dates)-min(dates));
            sp = spline(dates,rates);
            plot(xsp,ppval(sp,xsp)*100,'--')
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(dates) max(dates)])
        end
        
        function obj = cubicSplineFit(obj, dates, rates)
            hold on
            cs = csaps(dates,rates);
            xsp = linspace(min(dates),max(dates),max(dates)-min(dates));
            plot(xsp,ppval(cs,xsp)*100,'--')
            ytickformat('%.2f%%')
            datetick('x','dd/mm/yyyy')
            xlim([min(dates) max(dates)])
        end
        
        function obj = constrainedCubicSplineFit(obj, dates, rates, smoothingFactor)
            hold on
            x = dates;
            y = rates; 
            x_max = max(x);
            x_min = min(x);
            x_scaled = 10* (x - x_min) / (x_max - x_min);
            xsp = linspace(0,10,5000);
            cs = csaps(x_scaled,y,smoothingFactor);
            plot(xsp * (x_max - x_min) / 10 + x_min, ppval(cs,xsp)*100,'--');
            ytickformat('%.2f%%')   
            datetick('x','dd/mm/yyyy')
            xlim([min(dates) max(dates)])
            hold on
        end
    end
end

