createPortfolio; % Býr til ind og nonindexed
NonIndexedPortfolio = NonIndexedPortfolio.calculateCurves;
IndexedPortfolio = IndexedPortfolio.calculateCurves;

% Til að fá einhverja kúrvu
NonIndexedPortfolio = NonIndexedPortfolio.fitMethod("Swap rates","Lagrange interpolation",0,0);
% help fitMethod
curve = NonIndexedPortfolio.currentCurve;

mdates = datenum(NonIndexedPortfolio.maturity); %Maturity dates
dates = mdates-mdates(1)+1; %Dates for maturity of each bond
Rates = curve(dates) %Rate at maturity of each bond

plot(curve)
hold on 
plot(dates,Rates,'ob')

%% Verðleggja SWAP

Q = 1;
d = NonIndexedPortfolio.discountRates;

%Tekið úr function swap curve
obj = NonIndexedPortfolio.calculateCurves;
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

a = alpha;
f = frwRate/100;

PV_flt = a.*d.*Q.*f
PV_fix = a.*d.*Q.*(obj.swapRates)
w_k = (a.*d)/sum(a.*d)

%Vera í boði Mismunandi tími 
%Haka við receive eða ekki
%Hægt að stilla frequancy af greiðslum


swap_value = sum(PV_fix) - sum(PV_flt)

swap_rate = sum(PV_flt) / sum(a.*d.*Q)

frw_swap_rate  = (d(1)-d(length(a)))/sum(a.*d)
spot_swap_rate = (1-d(length(a)))   /sum(a.*d)

for i=2:length(a)
    r(i-1) = obj.zeroRates(i)-obj.zeroRates(i-1);
end

s_swap = sum(a.*d.*r)/sum(a.*d)


%Skoða swapbyzero

