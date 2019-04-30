%% FJÁRMÁL X - EXAM 3 - 27/03/2019 - JSH
% Q1 Part 4 - Nota case 1 úr Q4 fyrir r(t)
r0 = 0.055; 
sigma = 0.075; 
dt = 1/252; 
T = 3;
L = T/dt;

r = simulation_case_1(r0, sigma, dt, T, 1);
R = zeros(1,L);
F = zeros(1,L);
r(1) = r0;

for i = 2:L
    R(i) = r(i) - (1/6)*(sigma^2)*((L-i)*dt);
    F(i) = r(i) + (1/2)*(sigma^2)*((L-i)*dt)^2;
end

plot(R)
hold on
plot(F)
xlim([0 L])
legend('Term rate','Instantaneous forward rate')
title('Q1: Simulating the term rate and the interest rate')

%%  Q3 - See functions below
r0 = 0.045;
alpha = 0.1;
sigma = 0.05;
dt = 1/252;
T = 5; 
N = 10000;
L = T/dt; 
nbins = 100;
[R1, rT1] = simulation_case_1(r0, sigma, dt, T, N);
[R2, rT2] = simulation_case_2(r0, alpha, sigma, dt, T, N);
% Simulate bond price
[B1, bT1] = simulate_zbc(r0, sigma, alpha, 1, dt, T, N);
[B2, bT2] = simulate_zbc(r0, sigma, alpha, 2, dt, T, N);

% Plotting the results
subplot(3,2,1)
sgtitle("Question 3 - Simulations")
for i = 1:N
    plot(R1(i,:))
    hold on
end
title("Case 1 Simulation of interest rates")
xlim([0 L])

subplot(3,2,2) 
histfit(rT1, nbins,'normal')
title("Case 1 Distribution of interest rates")

subplot(3,2,3)
for i = 1:N
    plot(R2(i,:))
    hold on
end
xlim([0 L])
title("Case 2 Simulation of interest rates")

subplot(3,2,4)
histfit(rT2, nbins,'normal')
title("Case 2 Distribution of interest rates")

subplot(3,2,5)
for i = 1:100
    plot(B1(i,:))
    hold on
end
title("Case 1 Simulation of zero coupon bond price")
xlim([0 L])

subplot(3,2,6)
for i = 1:100
    plot(B2(i,:))
    hold on
end
title("Case 2 Simulation of zero coupon bond price")
xlim([0 L])

%% Q3 HELPER FUNCTIONS
function [R, rT] = simulation_case_1(r0, sigma, dt, T, N)
    % SIMULATION OF SHORT INTEREST RATES
    % Model: dr(t) = sigma*dW(t)
    L = T/dt;
    R = zeros(N,L);
    rT = zeros(1,N);
    dW = sqrt(dt)*randn(N,L);

    for i = 1:N
        R(i,1) = r0;
        for j = 2:L
            dR = sigma*dW(i,j);
            R(i,j) = R(i,j-1)+dR;
        end
        rT(i) = R(i,L);
    end    
end


function [R, rT] = simulation_case_2(r0, alpha, sigma, dt, T, N)
    % SIMULATION OF SHORT INTEREST RATES
    % Model: dr(t) = sigma*dW(t)
    L = T/dt;
    R = zeros(N,L);
    rT = zeros(1,N);
    dW = sqrt(dt)*randn(N,L);
    
    for i = 1:N
        R(i,1) = r0;
        for j = 2:L
            dR = alpha*dt + sigma*dW(i,j);
            R(i,j) = R(i,j-1)+dR;
        end
        rT(i) = R(i,L);
    end    
end

function [B, bT] = simulate_zbc(r0, sigma, alpha, sim_case, dt, T, N)
    % SIMULATING BOND PRICES FROM CASES 1 OR 2
    % Model: P(t,T) = exp(-r(t)(T-t))
    L = T/dt; 
    if(sim_case == 1)
        [R, rt] = simulation_case_1(r0, sigma, dt, T, N);
    else
        [R, rt] = simulation_case_2(r0, alpha, sigma, dt, T, N);
    end
    B = zeros(N,L);
    bT = zeros(1,N);
    
    for i = 1:N
        for j = 1:L
            B(i,j) = exp(-R(i,j)*((L-j)*dt)+(1/6)*(sigma^2)+((L-j)*dt^3));
        end
        bT(i) = B(i,L)*exp(-r0*T);
    end 
end