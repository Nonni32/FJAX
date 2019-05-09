%% Price of an interest rate swap
clc

obj = NonIndexedPortfolio; 
rates = obj.zeroRates';

%breyta obj.maturity í cell array
enddates = {};
for i = 1:length(obj.maturity)
      enddates(end+1) = {datestr(obj.maturity(i),'dd-mmm-yyyy')};
end
% RATES = 250, Settle 6 Enddates 6
Settle = today;
RateSpec = intenvset('Rates', rates,'StartDates',Settle, 'EndDates',enddates');
Maturity = datenum('15-Sep-2030'); %INPUT
coupon_rate = .025; 
spread = 20;

Settle = today;         %Input
RateSpec = intenvset('Rates', rates,'StartDates',Settle, 'EndDates',enddates');
Maturity = datenum('15-Sep-2030'); %Input
coupon_rate = .05;     %Ef NaN þá finnur fuctionið Swap rate - annars ákveðum við föstu greiðslunar
spread = 20;            %Input

LegRate = [coupon_rate spread];
LegType = [1 0];            %Velja milli fixed-floating, floating-fixed ... þetta er fixed/floating
%LatestFloatingRate = .005;  
 
[Price, SwapRate, AI, RecCF, RecCFDates, PayCF,PayCFDates] = ...
swapbyzero(RateSpec, LegRate, Settle, Maturity,'LegType',LegType,...
'AdjustCashFlowsBasis',true,...
'BusinessDayConvention','modifiedfollow')       %'LatestFloatingRate',LatestFloatingRate,


%% Pricing Forward swap  
clc

%Price a forward swap using the StartDate input 
%argument to define the future starting date of 
%the swap. 

Rates = 0.0325;
ValuationDate = datestr(today); 
StartDates = ValuationDate;     %Input - ef StartDate = Valueation date þá er það Spot swap

    
EndDates = '1-Jan-2023';    %Input
Compounding = 1;            %Input

%Create Rate Spec
RateSpec = intenvset('ValuationDate', ValuationDate,'StartDates', StartDates,...
'EndDates', EndDates,'Rates', Rates, 'Compounding', Compounding)

%Compute the price of a forward swap that starts in a year 
%(today+1year) and matures in 2 years with a forward swap rate of 4.27%. 

Settle = datestr(today);        %Input
StartDate = datestr(today+365); %Input
Maturity = '1-Jan-2021';        %Input
LegRate = [0.0427 10];          %Input


Price = swapbyzero(RateSpec, LegRate, Settle, Maturity, 'StartDate' , StartDate)

%% Find swap rate

LegRate = [NaN 10]; % Input
[Price, SwapRate] = swapbyzero(RateSpec, LegRate, Settle, Maturity,...
'StartDate' , StartDate)

