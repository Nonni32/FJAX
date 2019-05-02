function [c] = polyleastsquarefitting(x,y,m)
    % Dæmi um notkun
    % x = 0:10;
    % y = @(x) 3*x.^2+2*x+19;
    % a = polyleastsquarefitting(x,y(x),2)
    % f = @(x) a(1)+a(2).*x+a(3)*x.^2;
    % plot(x,y(x))
    % hold on
    % plot(x,f(x))
    n = size(x,1);
    if n == 1
        n = size(x,2);
    end
    b = zeros(m+1,1);
    for i = 1:n
       for j = 1:m+1
          b(j) = b(j) + y(i)*x(i)^(j-1);
       end
    end
    p = zeros(2*m+1,1);
    for i = 1:n
       for j = 1:2*m+1
          p(j) = p(j) + x(i)^(j-1);
       end
    end
    for i = 1:m+1
       for j = 1:m+1
          A(i,j) = p(i+j-1);
       end
    end
    c = A\b;
end

