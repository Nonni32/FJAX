%% Price of an interest rate swap
clc

obj = NonIndexedPortfolio; 
rates = obj.zeroRates';

%breyta obj.maturity í cell array
enddates = {};
for i = 1:length(obj.maturity)
      enddates(end+1) = {datestr(obj.maturity(i),'dd-mmm-yyyy')};
end

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

NonIndexedPortfolio = NonIndexedPortfolio.fitMethod("Swap rates","Lagrange interpolation",0,0);
% help fitMethod
curve = NonIndexedPortfolio.currentCurve;

mdates = datenum(NonIndexedPortfolio.maturity); %Maturity dates
dates = mdates-mdates(1)+1;                     %Dates for maturity of each bond
Rates = curve(dates)                            %Rate at maturity of each bond

plot(curve)
hold on 
plot(dates,Rates,'ob')


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


%% Swap using two interest-rate curves.

%Price a swap using two interest-rate curves. 
%First, define data for the two interest-rate term structures: 

StartDates = '01-May-2012'; 
EndDates = {'01-May-2013'; '01-May-2014';'01-May-2015';'01-May-2016'};
Rates1 = [0.0356;0.041185;0.04489;0.047741];
Rates2 = [0.0366;0.04218;0.04589;0.04974];

RateSpecReceiving = intenvset('Rates', Rates1, 'StartDates',StartDates,...
'EndDates', EndDates, 'Compounding', 1);

RateSpecPaying= intenvset('Rates', Rates2, 'StartDates',StartDates,...
'EndDates', EndDates, 'Compounding', 1);

RateSpec=[RateSpecReceiving RateSpecPaying]

%Define swap instruments

Settle = '01-May-2012';
Maturity = '01-May-2015';
LegRate = [0.06 10]; 
Principal = [100;50;100];

%Price three swaps using the two curves. 

Price = swapbyzero(RateSpec, LegRate, Settle, Maturity, 'Principal', Principal)

%% Price a Swap Using a Different Curve to Generate the Cash Flows of the Floating Leg

Settle = datenum('15-Mar-2013');
CurveDates = daysadd(Settle,360*[1/12 2/12 3/12 6/12 1 2 3 4 5 7 10],1);
OISRates = [.0018 .0019 .0021 .0023 .0031 .006  .011 .017 .021 .026 .03]';
LiborRates = [.0045 .0047 .005 .0055 .0075 .011 .016 .022 .026 .030 .0348]';

%Plot the dual curves.

figure,plot(CurveDates,OISRates,'r');hold on;plot(CurveDates,LiborRates,'b')
datetick
legend({'OIS Curve', 'Libor Curve'})

Create an associated RateSpec for the OIS and Libor curves.

OISCurve = intenvset('Rates',OISRates,'StartDate',Settle,'EndDates',CurveDates);
LiborCurve = intenvset('Rates',LiborRates,'StartDate',Settle,'EndDates',CurveDates);

%Define the swap.

Maturity = datenum('15-Mar-2018'); % Five year swap
FloatSpread = 0;
FixedRate = .025;
LegRate = [FixedRate FloatSpread];

%Compute the price of the swap instrument. The 
%LiborCurve term structure will be used to generate the cash 
%flows of the floating leg. The OISCurve term structure will 
%be used for discounting the cash flows.

Price = swapbyzero(OISCurve, LegRate, Settle,...
Maturity,'ProjectionCurve',LiborCurve)


%Compare results when the term structure OISCurve is used both 
%for discounting and also generating the cash flows of the floating leg.

PriceSwap = swapbyzero(OISCurve, LegRate, Settle, Maturity)




