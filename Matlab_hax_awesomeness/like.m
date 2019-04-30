close all
clear all
clc


delta_t = 1/250;
N = 2069;

% Lesa inn gögn úr excel skjali sem heitir Data.xlsx, sheet name, cells
inflation = xlsread('Data.xlsx','1','C12:C2620');
m1 = xlsread('Data.xlsx','2','C12:C2620');
m3 = xlsread('Data.xlsx','3','C12:C2620');
m12 = xlsread('Data.xlsx','4','C12:C2620');
mle(inflation)

% max likelihood function tekur inn fjölda datapunkta og datapunktana
[okkarK_m1, okkartheta_m1, okkarsigma_m1] = Max_Likelihood(length(m1),m1);
[okkarK_m3, okkartheta_m3, okkarsigma_m3] = Max_Likelihood(length(m3),m3);
[okkarK_m12, okkartheta_m12, okkarsigma_m12] = Max_Likelihood(length(m12),m12);
[okkarK_infla, okkartheta_infla, okkarsigma_infla] = Max_Likelihood(length(inflation),inflation);

[K_m1, theta_m1, sigma_m1] = MLE(m1,delta_t);
[K_m3, theta_m3, sigma_m3] = MLE(m3,delta_t);
[K_m12, theta_m12, sigma_m12] = MLE(m12,delta_t);
[K_infla, theta_infla, sigma_infla] = MLE(inflation,delta_t);

[okkary, okkardata, okkariteration] = ORNUHLEN(inflation(1),okkarK_infla,okkartheta_infla,okkarsigma_infla,delta_t,10000);
[y, data, iteration] = ORNUHLEN(inflation(1),okkarK_infla,okkartheta_infla,okkarsigma_infla,delta_t,10000);

for i = 1:iteration
    x(i) = i;
end
figure (1)
plot(x, y)
figure (2)
plot(x,okkary)