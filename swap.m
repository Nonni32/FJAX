createPortfolio; % B�r til ind og nonindexed
NonIndexedPortfolio = NonIndexedPortfolio.calculateCurves;
IndexedPortfolio = IndexedPortfolio.calculateCurves;

% Til a� f� einhverja k�rvu
NonIndexedPortfolio = NonIndexedPortfolio.fitMethod("Zero rates","Lagrange interpolation",0,0);
curve = NonIndexedPortfolio.currentCurve;
plot(curve)