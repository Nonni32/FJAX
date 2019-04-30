%% Lesa inn gögn
data = readtable("C:\Users\Jón Sveinbjörn\Documents\MATLAB\RIKB.csv");
Bonds = [datenum(data{:,2}) data{:,4} 100*ones(6,1) ones(6,1)];
Prices = [data{:,5}];
Settle = today-2;

%%  Reikna zero rates, forward rates og discount rate
[ZeroRates, CurveDates] = zbtprice(Bonds,Prices,Settle);
[ForwardRates, CurveDates] = zero2fwd(ZeroRates, CurveDates, Settle);
[DiscRates, CurveDates] = zero2disc(ZeroRates, CurveDates, Settle);

%% Reikna spline og cupic spline 
% d er fylki af öllum dagsetningum frá nálægasta maturity 
% að fjarlægasta maturity
d = linspace(min(CurveDates),max(CurveDates),max(CurveDates)-min(CurveDates));

sZR = spline(CurveDates, ZeroRates,d);
sFR = spline(CurveDates, ForwardRates,d);
sDR = spline(CurveDates, DiscRates,d);

csZR = csaps(CurveDates,ZeroRates);
csFR = csaps(CurveDates,ForwardRates);
csDR = csaps(CurveDates,DiscRates);

%% Teikna zero rates
plot(CurveDates,ZeroRates,'k','LineWidth',2) 
hold on
plot(d,sZR,'r--')
fnplt(csZR,'b--') 
hold off
datetick('x','dd/mm/yyyy')
xlim([min(CurveDates) max(CurveDates)])
title('Zero rate curve')
legend('Zero rates','Spline','Cubic spline')

%% Teikna forward rates
plot(CurveDates,ForwardRates,'k','LineWidth',2); 
hold on
plot(d,sFR,'r--')
fnplt(csFR,'b--') 
hold off
datetick('x','dd/mm/yyyy')
xlim([min(CurveDates) max(CurveDates)])
title('Forward rate curve')
legend('Forward rates','Spline','Cubic spline')

%% Teikna discount rate
plot(CurveDates,DiscRates,'k','LineWidth',2)
hold on
plot(d,sDR,'r--')
fnplt(csDR,'b--')
datetick('x','dd/mm/yyyy')
xlim([min(CurveDates) max(CurveDates)])
title('Discount rate curve')
legend('Discount rates','Spline','Cubic spline')

%% Reikna swap rate með spline og csaps
% i táknar tímabil swapsins, fyrsta greiðsla er eftir 3/2 ár og síðasta
% eftir 22/2 ár
i = 3:22;

S_fix = 0.5*sDR(round(365.*i/2));
S_float = 0.5*sFR(round(365.*i/2)).*sDR(round(365.*i/2));
S_sr = sum(S_float)/sum(S_fix)

CS_fix = 0.5*fnval(today+365.*i/2,csDR);
CS_float = 0.5*fnval(today+365.*i/2,csFR).*fnval(today+365.*i/2,csDR);
CS_sr = sum(CS_float)/sum(CS_fix)

%% Verðleggja floating leg sem bond með L = 100 með fixed rate
% Gáfum okkur nominal value L
L = 100;
V_fix_S = sum(L*S_sr*S_fix)+L*sDR(365*22/2)
V_fix_CS = sum(L*CS_sr*CS_fix)+L*fnval(today+365*22/2,csDR)

V_float_S = sum(L*S_float)+L*sDR(365*22/2)
V_float_CS = sum(L*CS_float)+L*fnval(today+365*22/2,csDR)
