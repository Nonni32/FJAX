%% ICELANDIC BOND MARKET 
%% Lesa inn g�gn af bonds.is
createPortfolio;    
% N�na eru til 2 portfolio object, NonIndexedPortfolio og IndexedPortfolio

%% �etta eru �ll curve og fitting methods � bo�i
curves = ['Yield', 'Zero rates', 'Forward rates', 'Discount rates', 'Swap rates'];
fitMethods = ['Bootstrapping','Nelson-Siegel','Nelson-Siegel-Svensson','Polynomial',... 
    'Lagrange interpolation','Spline','Cubic spline','Constrained cubic spline'];

PolynomialDegree = 2;       % Fyrir Polynomial
SmoothingFactor = 0.75;     % Fyrir Constrained cubic spline [0,1]

%% Til a� fitta curve me� �kve�inni a�fer� + plotta
NonIndexedPortfolio = NonIndexedPortfolio.fitMethod('Forward rates', 'Lagrange interpolation',PolynomialDegree, SmoothingFactor);
IndexedPortfolio = IndexedPortfolio.fitMethod(curves(2),fitMethods(6),PolynomialDegree, SmoothingFactor);
% N�na eru �essi fittu�u curve geymd sem .currentCurve � b��um portfolioum

%%  Til a� plotta
plot(datesNI, NonIndexedPortfolio.currentCurve)
% plot(datesI, IndexedPortfolio.currentCurve) % Samb�rilegt fyrir indexed

%% L�ka h�gt a� plotta gagnapunktana me�:
% NonIndexedPortfolio.zeroCurve;
% NonIndexedPortfolio.yieldCurve;
 NonIndexedPortfolio.forwardCurve;
% NonIndexedPortfolio.discountCurve;
% NonIndexedPortfolio.swapCurve;

%% Til a� plotta gagnapunkta OG fitted curve --> Sj� bondGUI
bondGUI

%% INTEREST RATE SIMULATIONS
% Model � bo�i: 'Simple', 'Brownian', 'Vasicek'
% Sj� help interestRate fyrir �tsk�ringar
model = ['Simple', 'Brownian', 'Vasicek'];
initialRate = 0.05;
stepSize = 1/250;   
volatility = 0.03;
speedOfReversion = 0.25;    % Nota� fyrir alpha � brownian og kappa � vasicek
longTermMeanLevel = 0.035;  % Nota� fyrir theta � vasicek
maturity = 5;
nrOfSimulations = 1000;

IR1 = interestRate(model(1), initialRate, stepSize, volatility, speedOfReversion, longTermMeanLevel, maturity, nrOfSimulations);
IR2 = interestRate(model(2), initialRate, stepSize, volatility, speedOfReversion, longTermMeanLevel, maturity, nrOfSimulations);
IR3 = interestRate(model(3), initialRate, stepSize, volatility, speedOfReversion, longTermMeanLevel, maturity, nrOfSimulations);

%% Simulatea vextina
IR1.plotSimulations
IR2.plotSimulations
IR3.plotSimulations

%% S�na histogram fyrir interest rate modeli�
IR1.histModel
IR2.histModel
IR3.histModel

%% S�na hvernig MLE batnar me� fj�lda �trana
% H�kka maturity � IR3 til a� b�ta ni�urst��una
IR3.estimationImprovement

%% S�na hvernig OLS batnar me� fj�lda �trana
% H�kka maturity � IR3 til a� b�ta ni�urst��una
IR3.estimationImprovementOLS

%% H�gt a� sko�a �etta interactive me� interestRateGUI
interestRateGUI

%% OPTION PRICER
StrikePrice = 1.0;
OptionMaturity = 4;     % Ver�ur a� vera minna en IR.maturity

% B�a til pricing model me� �llum interest rate modelunum
PM1 = pricingModel(IR1, StrikePrice, OptionMaturity)
PM2 = pricingModel(IR2, StrikePrice, OptionMaturity)
PM3 = pricingModel(IR3, StrikePrice, OptionMaturity)

%% Plot zero coupon bonds me� Simple
PM1.plotBonds

%% Plot zero coupon bonds me� Brownian
PM2.plotBonds

%% Plot zero coupon bonds me� Vasicek
PM3.plotBonds


