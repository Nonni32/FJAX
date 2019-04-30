classdef bond
    % BOND
    properties
        % HÆGT AÐ BÆTA Í ÞETTA 
        ticker
        duration
        ask
        bid
        lastPrice
        lastYield
        yield
        coupon
        interest
    end
    
    methods
        function obj = bond(overview, attributes)
            % Assigning values to bond (from www.bonds.is)
            obj.ticker = overview.shortName;
            obj.duration = str2double(overview.duration([1:strfind(overview.duration," ")-1]));
            obj.ask = str2double(overview.askPrice);
            obj.bid = str2double(overview.bidPrice);
            obj.lastPrice = str2double(overview.lastValidPrice);
            obj.lastYield = str2double(overview.lastValidYield([1:strfind(overview.lastValidYield,"%")-1]))/100;
            obj.yield = str2double(overview.yield([1:strfind(overview.yield,"%")-1]))/100;
               
            
            if attributes.attributes(7).name == "Coupon"
                obj.coupon = attributes.attributes(7).value;
            else
                obj.coupon = attributes.attributes(6).value;
            end
                
            for i = 6:10
                if attributes.attributes(i).name == "Interest"
                    obj.interest = str2double(attributes.attributes(i).value([1:strfind(attributes.attributes(i).value,"%")-1]))/100;
                end
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

