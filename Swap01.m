%% Price of an interest rate swap
clc

obj = NonIndexedPortfolio; 
rates = obj.zeroRates';

%breyta obj.maturity í cell array
enddates = {};
for i = 1:length(obj.maturity)
      enddates(end+1) = {datestr(obj.maturity(i),'dd-mmm-yyyy')};
end

Settle = today;
RateSpec = intenvset('Rates', rates,'StartDates',Settle, 'EndDates',enddates');
Maturity = datenum('15-Sep-2030');
coupon_rate = .025;
spread = 20;

LegRate = [coupon_rate spread];
LegType = [1 0]; % fixed/floating
LatestFloatingRate = .005;
 
[Price, SwapRate, AI, RecCF, RecCFDates, PayCF,PayCFDates] = ...
swapbyzero(RateSpec, LegRate, Settle, Maturity,'LegType',LegType,...
'LatestFloatingRate',LatestFloatingRate,'AdjustCashFlowsBasis',true,...
'BusinessDayConvention','modifiedfollow')


%% Pricing Forward swap  
clc

%Price a forward swap using the StartDate input 
%argument to define the future starting date of 
%the swap. 

Rates = 0.0325;
ValuationDate = datestr(today);
StartDates = ValuationDate;

%Innsetning á custom ending date
EndDates = '1-Jan-2023';
Compounding = 1;

%Create Rate Spec
RateSpec = intenvset('ValuationDate', ValuationDate,'StartDates', StartDates,...
'EndDates', EndDates,'Rates', Rates, 'Compounding', Compounding)

%Compute the price of a forward swap that starts in a year 
%(today+1year) and matures in 2 years with a forward swap rate of 4.27%. 

Settle = datestr(today);
StartDate = datestr(today+365);
Maturity = '1-Jan-2021';
LegRate = [0.0427 10];


Price = swapbyzero(RateSpec, LegRate, Settle, Maturity, 'StartDate' , StartDate)

%% Find swap rate

LegRate = [NaN 10];
[Price, SwapRate] = swapbyzero(RateSpec, LegRate, Settle, Maturity,...
'StartDate' , StartDate)

