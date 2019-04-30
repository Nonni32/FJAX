function [K,theta,sigma] = Max_Likelihood(N,data)

delta_t = 1/250;
st = data;
N = 1:1:N;
t = N;


sx = nansum(st)-st(length(t));
sy = nansum(st) - st(1);

for i = 1:length(t)
        s_2(i) = st(i)^2;
        
        if i ~= 1
            sxy(i) = st(i-1)*st(i);
            
        end   
end

sxx = nansum(s_2) - s_2(length(t))^2;
syy = nansum(s_2) - s_2(1)^2;
sxy = nansum(sxy);

theta = (sy*sxx - sx*sxy)/(length(t)*(sxx-sxy)-sx^2+sx*sy);
%est_mu = (Sy*Sxx - Sx*Sxy)/( datalength*(Sxx - Sxy) - (Sx.^2 - Sx*Sy) );

%deilt med 100 ??
K = -(1/(delta_t))*log((sxy-theta*(sx+sy)+length(t)*theta^2)/(sxx-2*theta*sx+length(t)*theta^2))/100;
s_hattur = (1/length(t))*(syy - 2*sx*exp(-K*(delta_t)) + sxx*exp(-2*K*(delta_t)) - 2*theta*(sy-sx*exp(-K*delta_t))*(1-exp(-K*delta_t))+length(t)*theta^2*(1-exp(-K*delta_t))^2);

%deilt med 100 ??
sigma = sqrt((2*K*s_hattur^2)/(1-exp(-2*K*(delta_t))))/100;

end

