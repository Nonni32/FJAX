clear all
close all
clc

x = [1 2 3 4];
f = [0.05 0.054 0.057 0.051];

[P,R,S] = lagrange(x,f);


xx = 0 : 0.01 : 4.5;
figure (1)
plot(xx,polyval(P,xx),x,f,'or',R,S,'.b',xx,spline(x,f,xx),'--r')
grid
axis([0 4.5 0.041 0.06])
xlabel("X")
ylabel("P(X)")

title("Approximation P(x) for x = [0,4.5]")
figure(2)
plot(x,f,'-or')
axis([0 4.5 0.041 0.06])
grid
xlabel("X")
ylabel("f(X)")
title("Plot of (Xi,f(xi))")