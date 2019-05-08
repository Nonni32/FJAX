%% Price of an interest rate swap
clc

Settle = today;
zerorates = [.005 .0075 .01 .014 .02 .025 .03]';
enddates = {'08-Dec-2010','08-Jun-2011','08-Jun-2012','08-Jun-2013','08-Jun-2015','08-Jun-2017','08-Jun-2020'}';
coupon_rate = 0.04; % NaN til að fá swap rate
Spread = 50;
LegRate = [coupon_rate Spread]; % [CouponRate Spread] 
LegType = [1 0]; % fixed/floating
Maturity = datenum('15-Sep-2020');
LatestFloatingRate = .04;

RateSpec = intenvset('Rates',zerorates ,'StartDates',Settle, 'EndDates',enddates);

%AI = Accrued interest 

[Price, SwapRate, AI, RecCF, RecCFDates, PayCF,PayCFDates] = ...
swapbyzero(RateSpec, LegRate, Settle, Maturity,'LegType',LegType,...
'LatestFloatingRate',LatestFloatingRate,'AdjustCashFlowsBasis',true,...
'BusinessDayConvention','modifiedfollow')


%% Forward swap  

Rates = 0.0325;
ValuationDate = '1-Jan-2012';
StartDates = ValuationDate;
EndDates = '1-Jan-2018';
Compounding = 1;

%Create Rate Spec
RateSpec = intenvset('ValuationDate', ValuationDate,'StartDates', StartDates,...
'EndDates', EndDates,'Rates', Rates, 'Compounding', Compounding)

Settle ='1-Jan-2012';
StartDate = '1-Jan-2013';
Maturity = '1-Jan-2016';
LegRate = [0.0427 10];

Price = swapbyzero(RateSpec, LegRate, Settle, Maturity, 'StartDate' , StartDate)

%find swap rate
LegRate = [NaN 10];
[Price, SwapRate] = swapbyzero(RateSpec, LegRate, Settle, Maturity,...
'StartDate' , StartDate)
