createPortfolio; % Býr til ind og nonindexed
NonIndexedPortfolio = NonIndexedPortfolio.calculateCurves;
IndexedPortfolio = IndexedPortfolio.calculateCurves;

% Til að fá einhverja kúrvu
NonIndexedPortfolio = NonIndexedPortfolio.fitMethod("Zero rates","Lagrange interpolation",0,0);
curve = NonIndexedPortfolio.currentCurve;
plot(curve)