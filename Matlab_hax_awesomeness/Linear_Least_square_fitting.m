function [a,b] = Linear_Least_square_fitting(x,y)
    %We search for coefficients a and b such that the function
    % f(x) = ax+b gives best possible to the pairs
    % pi = (xi,yi) ; i 1,2,.....,N
    
    N = length(x);
    for i = 1:N;
        Sx(i) = x(i);
        Sy(i) = y(i);
        Sxx(i) = x(i)^2;
        Sxy(i) = x(i)*y(i);
    end
    Sx = sum(Sx);
    Sy = sum(Sy);
    Sxx = sum(Sxx);
    Sxy = sum(Sxy);
    
    a = (Sx*Sy-N*Sxy)/(Sx^2-N*Sxx);
    b = (Sx*Sxy-Sy*Sxx)/(Sx^2-N*Sxx);
   
    
end
