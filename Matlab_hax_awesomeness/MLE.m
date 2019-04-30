function [ est_mu, est_la, est_sigma ] = MLE( data, dt );
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%Parameter estimation based on assumed Ornstein-Uhlenbeck dynamics


ry = data;
datalength = length(ry); 

for i=1:datalength-1
    TSx(i)  = ry(i);
    TSy(i)  = ry(i+1);
    TSxx(i) = ry(i)^2;
    TSxy(i) = ry(i)*ry(i+1);
    TSyy(i) = ry(i+1)^2;
end
Sx  = nansum(TSx);
Sy  = nansum(TSy);
Sxx = nansum(TSxx);
Sxy = nansum(TSxy);
Syy = nansum(TSyy);

est_mu = (Sy*Sxx - Sx*Sxy)/( datalength*(Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
est_la = -(1/dt)*log(    ( Sxy - est_mu*Sx - est_mu*Sy + datalength*est_mu^2 )/(  Sxx - 2*est_mu*Sx + datalength*est_mu^2 )  );

al = exp(-est_la*dt);

sig_sq = (1/datalength)*( Syy - 2*al*Sxy + al^2*Sxx - 2*est_mu*(1 - al)*(Sy - al*Sx) + datalength*est_mu^2*(1 - al)^2);

%est_sigma_sq = sig_sq*(2*est_la/(1 - al^2));

est_sigma = sqrt(sig_sq*2*est_la/(1 - al^2));

est_mu;
est_la;
est_sigma;

%[mu est_mu;la est_la;sigma est_sigma];



end

