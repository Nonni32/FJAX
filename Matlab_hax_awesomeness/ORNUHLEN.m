function [ y,ry, NoOfIt] = ORNUHLEN(starting,k,theta,sigma,dt,NoOfIt );

%Sverrir Olafsson, 01-March-2019

%This function simulates the mean reverting Ornstein-Uhlenbeck SDE NoOfIt
%iterations


x  = starting;  %initialisation
r  = randn(1,NoOfIt);

 for i = 1:NoOfIt                                 %Number of iterations 
     
     dx = k*(theta - x)*dt + sigma*sqrt(dt)*r(i);    %increment in Ornstein-Uhlenbeck process
     x = x + dx;                                  %Ornstein-Uhlenbeck process
     y(i)= x;                                     %Ornstein-Uhlenbeck process  
 end                                              %Number of iterations
 
T   = 1:1:NoOfIt;
ry  = [starting y];
rr  = [0 r];
rT  = 0:1:NoOfIt;

rOP = [rT' (rT*dt)' ry' rr'];  
 
%Sx  = sum(ry(1:NoOfIt));
%Sy  = sum(ry(2:NoOfIt+1));

for i=1:NoOfIt
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

est_theta = (Sy*Sxx - Sx*Sxy)/( NoOfIt*(Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
est_k = -(1/dt)*log(    ( Sxy - est_theta*Sx - est_theta*Sy + NoOfIt*est_theta^2 )/(  Sxx - 2*est_theta*Sx + NoOfIt*est_theta^2 )  );

al = exp(-est_k*dt);

sig_sq = (1/NoOfIt)*( Syy - 2*al*Sxy + al^2*Sxx - 2*est_theta*(1 - al)*(Sy - al*Sx) + NoOfIt*est_theta^2*(1 - al)^2);

%est_sigma_sq = sig_sq*(2*est_la/(1 - al^2));

est_sigma = sqrt(sig_sq*2*est_k/(1 - al^2));

est_k;
est_theta;
est_sigma;

[k est_k;theta est_theta;sigma est_sigma];



end

