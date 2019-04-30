clear all
close all
clc

%% Linear least square fitting
clear all
close all
clc

x = [1 2 3 4 5 6];
y = [1.1 1.9 3.2 4.3 4.8 5.5];

[a,b] = Linear_Least_square_fitting(x,y)

f = @(x) a*x+b;
figure(1)
plot(x,f(x))
hold on 
plot (x,y)
title("Linear Least square fitting");
xlabel("X")
ylabel("f(x)")
legend("X-Y","Linear least square fitting")

%% Curve fitting by polynomial least square
clear all
close all
clc

x = 0:10;
y = @(x) 2*x.^4 + x.^3 - 16*x.^2 +2;
degree = 5;

[a] = polyleastsquarefitting(x,y,degree)
m = length(x);
counter = 1;
for i = 1:m
    for k = 0:degree
        gaur(counter) = a(counter)*x(i)^k
        counter = counter +1 
    end
    p(i) = sum(gaur);
    counter = 1;
end

for i = 1:m
    E(i) = (y(i)-p(i)).^2
end
Error = sum(E)

plot(x,y(x),'-')
hold on 
plot(x,p,'-.')
title("Curve fitting by polynomial least square fitting");
legend("X-Y","polynomial fitting");

%% Lagrange interpolation
clear all
close all
clc

X = [1 2 3 4];
Y = [0.05 0.054 0.057 0.051];

[P,R,S] = lagrangepoly(X,Y);


xx = 0 : 0.01 : 4.5;
figure (1)
plot(xx,polyval(P,xx),X,Y,'or',R,S,'.b',xx,spline(X,Y,xx),'--r')
grid
axis([0 4.5 0.041 0.06])
xlabel("X")
ylabel("P(X)")

title("Approximation P(x) for x = [0,4.5]")
figure(2)
plot(X,Y,'-or')
axis([0 4.5 0.041 0.06])
grid
xlabel("X")
ylabel("f(X)")
title("Plot of (Xi,f(xi))")




%% Splines
clear all
close all
clc

% s = spline(x,y,xq) returns a vector of interpolated values s 
% corresponding to the query points in xq. The values of s are 
% determined by cubic spline interpolation of x and y.

% Cubic spline
x = [0 1 2.5 3.6 5 7 8.1 10];
y = sin(x);
xx = 0:.25:10;
yspline = spline(x,y);
yy = spline(x,y,xx);
figure(1)
plot(x,y,'o',xx,yy);

% Spline
x = -4:4;
y = [0 .15 1.12 2.36 2.36 1.46 .49 .06 0];
cs = spline(x,y);
xx = linspace(-4,4,101);
figure(2)
plot(x,y,'o',xx,ppval(cs,xx),'-');


