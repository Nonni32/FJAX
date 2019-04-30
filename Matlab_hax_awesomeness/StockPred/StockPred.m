%% MATLAB Code for Volatility modeling using GARCH
%% Authors: Karan Mendiratta, Vinay C Patil, April 2010 ©
%% Usage: Obtain the stock data from Downloader Excel, an MS Excel Plugin
%% (from Yahoo Finance), select the row from the required .xls/.xlsx sheet
%% as reference data for the garch model.
%% Output: sig and mu (used by the C++ code for prediction)
clc;
clear all;


price=xlsread('C:\xxxx\xxxx\xxxx\xxxx.xlsx','E3:E3840');  % Specify the directory where file is stored and the desired column values
 
temp=price(length(price));
 
%% GARCH parameters
spec = garchset('P',1,'Q',1);
[coeff]=garchfit(spec,price);
[sig,mu]=garchpred(coeff,price,10); % Forcast for 10 days, you can specify a different time period, or just use input() from command window
                                    % to enter it at run time
 
% Writing the parameters to a file 
 
fid=fopen('C:\xxxx\xxxx\xxxx\forecast.txt','w');    % Specify the directory where the file is, for the computed values to be written
fprintf(fid,'%f\n',temp);
 
    for i=1:length(sig)
    fprintf(fid,'%f\n',sig(i)/100);
    end
    
    for j=1:length(mu)
    fprintf(fid,'%f\n',mu(j)/100);
    end
    
 fclose(fid);
