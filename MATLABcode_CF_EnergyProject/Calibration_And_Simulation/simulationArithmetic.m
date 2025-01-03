function [S,X,Y,F] = simulationArithmetic(N_sim,t,dt,T1,T2,...
    s,X_0,m,alpha,sigma,Y_0,n,beta,eta,k)
% Function to simulate via an Arithmetic model the Spot price at time t and
% the Future prices at time t, with start delivery in T1 and settlement in
% T2.
%
% INPUTS:
% N_sim:    Number of simulations
% t:        Time until the simulation is done
% dt:       Time step size
% T1:       Start delivery date
% T2:       Settlement date
% s:        Seasonality parameters
% X_0:      Gaussian part initial state
% m:        Number of X processes
% alpha:    Mean reversion speeds for X
% sigma:    Volatilities for X
% Y_0:      Jump part initial state
% n:        Number of Y processes
% beta:     Mean reversion speeds for Y
% eta:      Jumps intensities for Y processes
% k:        Inverse Gaussian parameters
%
% OUTPUTS:
% S:        Simulated Spot price
% X:        Simulated Gaussian driven part
% Y:        Simulated Inverse Gaussian driven part
% F:        Simulated Future price

% Time steps
time_steps = t / dt;

% Normal Part Simulation
paths_N = zeros(N_sim,time_steps,m);
samples_N = rand(N_sim,time_steps,m);
for i=1:m
paths_N(:,:,i) = icdf('Normal', samples_N(:,:,i),0,dt)...
    .*exp(-alpha(i)*((dt:dt:t)-dt/2));
end

% IG part
paths_IG = zeros(N_sim,time_steps,n);
samples = rand(N_sim,time_steps,n);
for i=1:n
paths_IG(:,:,i) = icdf('InverseGaussian', samples(:,:,i),dt,dt^2/k(i))...
    .*exp(-beta(i)*((dt:dt:t)-dt/2));
end

% Build X
X = zeros(N_sim,time_steps,m);
for i=1:m
X(:,:,i) = X_0(i) .* exp(-alpha(i)*((dt:dt:t)-dt/2)) + sigma(i) .* ...
    cumsum(paths_N(:,:,i),2);
end

% Build Y
Y = zeros(N_sim,time_steps,n);
for i=1:n
Y(:,:,i) = Y_0(i) .* exp(-beta(i)*((dt:dt:t)-dt/2)) + eta(i) .* ...
    cumsum(paths_IG(:,:,i),2);
end

% Spot Price
S = repmat(Lambda((dt:dt:t)-dt/2,s),N_sim,1) + sum(Y,3) + sum(X,3);

% Future Price
F = Future(t,T1,T2,X(:,end,:),Y(:,end,:),s,alpha,m,beta,eta,n);

end

