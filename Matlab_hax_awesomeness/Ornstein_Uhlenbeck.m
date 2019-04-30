function [est_k, est_th,est_sig, y_vec] = Ornstein_Uhlenbeck(k,th,sig,x0,dt,no_itr );

x  = x0;
r  = randn(1,no_itr);

 for i = 1:1:no_itr                                 
     dr = k*(th - x)*dt + sig * sqrt(dt) * r(i); 
     x = x + dr;                                  
     y_vec(i)= x;                                       
 end                                              
 
T   = 1:1:no_itr;
y  = [x0 y_vec];

SSx  = y(T);
SSy  = y(T+1);
SSxx = y(T).^2;
SSxy = y(T).*y(T+1);
SSyy = y(T+1).^2;

Sx  = sum(SSx);
Sy  = sum(SSy);
Sxx = sum(SSxx);
Sxy = sum(SSxy);
Syy = sum(SSyy);

est_th = (Sy*Sxx - Sx*Sxy)/( no_itr * (Sxx - Sxy) - (Sx.^2 - Sx*Sy) );
est_k = -(1/dt)*log(( Sxy - est_th*Sx - est_th*Sy + no_itr*est_th^2 )/(  Sxx - 2*est_th*Sx + no_itr*est_th^2 ));

s_hat = (1/no_itr)*( Syy - 2*exp(-est_k*dt)*Sxy + exp(-est_k*dt)^2*Sxx - 2*est_th*(1 - exp(-est_k*dt))*(Sy - exp(-est_k*dt)*Sx) + no_itr*est_th^2*(1 - exp(-est_k*dt))^2);
est_sig = sqrt(s_hat*2*est_k/(1 - exp(-est_k*dt)^2));

[est_k est_th est_sig]

end

