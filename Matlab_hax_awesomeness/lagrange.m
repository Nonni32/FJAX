function [P,R,S] = lagrange(X,Y,XX)

if size(X,1) > 1;  X = X'; end
if size(Y,1) > 1;  Y = Y'; end
if size(X,1) > 1 || size(Y,1) > 1 || size(X,2) ~= size(Y,2)
  error('both inputs must be equal-length vectors')
end

N = length(X);

pvals = zeros(N,N);

for i = 1:N
  pp = poly(X( (1:N) ~= i));
  pvals(i,:) = pp ./ polyval(pp, X(i));
end

P = Y*pvals;

if nargin==3
  YY = polyval(P,XX);
  P = YY;
end

if nargout > 1
  R = roots( ((N-1):-1:1) .* P(1:(N-1)) );
  if nargout > 2
    S = polyval(P,R);
  end
end
