createPortfolio; % Býr til ind og nonindexed
NonIndexedPortfolio = NonIndexedPortfolio.calculateCurves;
IndexedPortfolio = IndexedPortfolio.calculateCurves;

% Til að fá einhverja kúrvu
NonIndexedPortfolio = NonIndexedPortfolio.fitMethod("Swap rates","Lagrange interpolation",0,0);
% help fitMethod
curve = NonIndexedPortfolio.currentCurve;
plot(curve)