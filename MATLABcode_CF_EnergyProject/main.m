%% Energy Finance project - Main script
% Authors:
% Giacomo Manfredi
% Edoardo Pariani
% Andrea  Tarditi
% Nicolò  Toia
% Matteo  Torba
%
% Date: 2024-12-10

clc, clear, close all;
% Add paths
addpath('Cost_Functions');
addpath('Model_Functions');
addpath('Calibration_And_Simulation');
addpath('Market_Data');
addpath('Metrics_And_Plots');

% Set seed for reproducibility
seed = rng(42);

%% Dataset extraction

data = readtable('DATA_FREEX.xlsx','Sheet','Prices');

% Save the options data
deliveries = data{:,1};
names = data{:,2};
prices = data{:,3};

% Initialize the settlements dates
settlements = deliveries;
% Grouping contracts to identify settlement
% Monthly
settlements(1:7) = settlements(1:7) + calmonths(1);
% Quarterly
settlements(8:14) = settlements(8:14) + calmonths(3);
% Yearly
settlements(15:end) = settlements(15:end) + calmonths(12);

% Compute the tenors
tenors = yearfrac(deliveries,settlements);

% Set today's date
today = '4-Nov-2024';
% Compute the time to delivery
ttd = yearfrac(today, deliveries, 0);

%% Sample simulation of our model
% Number of simulations
N_sim = 1;

% Simulation time parameters
t = 1;
dt = 1/252;
t1 = 2;
t2 = 3;

% Initial conditions and parameters
% Seasonality term
s = [2,0,-0.1];
% Gaussian driven term X
m = 0;          % Number of X processes
X_0 = ones(1,m);       % Initial point for X
alpha = ones(1,m);     % X mean reversion speeds
sigma = ones(1,m);     % X volatility terms
% Inverse Gaussian driven term Y
n = 2;              % Number of Y processes
Y_0 = ones(1,n);    % Initial point for Y
beta = [1 1];       % Y mean reversion speeds
eta = [2 2];        % Y jumps intensity
k = [.1 .1];        % Inverse Gaussian parameters

% Run the simulation
[S,X,Y,~] = ...
    simulationArithmetic(N_sim,t,dt,t1,t2,...
    s,X_0,m,alpha,sigma,Y_0,n,beta,eta,k);

% Plot the simulation
figure;
hold on;
plot(S);    % plot the Arithmetic Spot price
for i=1:m
    plot(X(:,:,i)') % plot the X processes
end
for i=1:n
    plot(Y(:,:,i)') % plot the Y processes
end
plot(Lambda((dt:dt:t)-dt/2,s))  % plot the seasonality
hold off
% Add title and legend
title("Sample Simulation of Our Model");
legend('Arithmetic Spot Pirce', 'Jump1 process', 'Jump2 process', 'Seasonality')

%% Model Functions
% Faster Function handles for calibration since they require only one
% Y_t X_t at a time instead of a batch like the simulation

% Theta function for Futures (Integrals Solved)
Theta_FUT = @(t,T1,T2,beta,eta,n) ...
    sum(arrayfun(@(i) ...
    eta(i)/beta(i)^2*(exp(-beta(i)*(T2-t)) - ...
    exp(-beta(i)*(T1-t)) + ...
    beta(i)*(T2-T1)),1:n)) * 1/(T2-T1);

% Integrated Seasonality function Lambda for Futures
LambdaInt = @(T1,T2,s) ...
    1/(T2-T1) * (s(1)/(2*pi)*(cos(2*pi*T1)-cos(2*pi*T2))+ ...
    s(2)*(T2-T1)+s(3)/2*(T2^2-T1^2));

% Change of measure for the jump component
Y_Q = @(Y_t,t,beta,eta) ... 
    Y_t - eta/beta * (1-exp(-beta*t));

% Future price as in Propostion 4.14 of "Stochastic Modelling of
% electricity and related markets" by  F. E. Benth, J. S. Benth and S.
% Koekebakker
F = @(t,T1,T2,s,alpha,m,beta,eta,n,X_t,Y_t) ...
    LambdaInt(T1, T2, s) + ...
    Theta_FUT(t, T1, T2, beta, eta, n) + ...
    sum(arrayfun(@(i)...
    X_t(i)*(exp(-alpha(i)*(T1-t))-exp(-alpha(i)*(T2-t)))/(alpha(i)*(T2-T1))...
    ,1:m)) + ...
    sum(arrayfun(@(i)...
    Y_Q(Y_t(i), t , beta(i), eta(i))*(exp(-beta(i)*(T1-t)) - ...
    exp(-beta(i)*(T2-t)))/(beta(i)*(T2-T1))...
    ,1:n));

%% Arithmetic model based on a Inverse Gaussian OU model
disp('==========================================================================================================================================')
disp('                                           Arithmetic Model with m=p=0 n=2')
disp('==========================================================================================================================================')

%% Calibration
% Number of X processes
m = 0;
% Number of Y processes
n = 2;
% Number of parameters for seasonality
S_p = 3;

% Time variables
t = 0;             % Current time
T1 = ttd;          % Time to delivery
T2 = ttd + tenors; % Time to settlement

% Parametrize Futures Function
F_params = @(t,T1,T2,p,m,n,X_t,Y_t) F(t,T1,T2,p(1:S_p),...
    p(S_p+1:S_p+m),m,...
    p(S_p+1+m:S_p+m+n),p(end-n+1:end),n,X_t,Y_t);

% Calibration via fmincon
flag = 1; % flag variable to calibrate via fmincon
% Choosing Objective Functions
objFunc1 = @(p, F_params, prices, T1, T2, m, n, X_t, Y_t) ...
    MSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);
objFunc2 = @(p, F_params, prices, T1, T2, m, n, X_t, Y_t) ...
    MSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Start the timer for the calibration time
tic
% Run the calibration
[p_opt_IG_fmincon, err] = ...
    calibrationArithmetic(S_p, m, n, F_params, ...
    prices, t, T1, T2, flag, objFunc1, objFunc2);
time_calib_IG_fmincon = toc; % stop the timer

% Build a table to display the calibrated parameters
p_opt_Table_IG_fmincon = table(p_opt_IG_fmincon(1), p_opt_IG_fmincon(2), p_opt_IG_fmincon(3), p_opt_IG_fmincon(4), p_opt_IG_fmincon(5), p_opt_IG_fmincon(6), p_opt_IG_fmincon(7), err,...
    'VariableNames',{'A', 'B', 'C', 'β_1', 'β_2', 'η_1', 'η_2', 'Calibration Error (MSE)'},'RowNames',{'m=p=0, n=2  via fmincon'});
% Display the calibrated parameters
fprintf('\n')
disp('==========================================================================================================================================')
disp('                                  CALIBRATED PARAMETERS m=p=0 n=2 via fmincon')
disp('==========================================================================================================================================')
disp(p_opt_Table_IG_fmincon);

% Metrics to evaluate the goodness of the calibration
% Compute the metrics and store them in a table
MetricsTableY_fmincon = evaluateMetrics(p_opt_IG_fmincon, F_params, prices, T1, T2, m, n, ones(1,m), ones(1,n));
MetricsTableY_fmincon.Properties.RowNames = {'m=p=0, n=2 via fmincon'};

% Display the metrics
disp('==========================================================================================================================================')
disp('                                             Metrics to evaluate the goodness of the calibration')
disp('==========================================================================================================================================')
disp(MetricsTableY_fmincon);

% Display the time needed for calibration
fprintf('\nTime needed for the calibration via fmincon: %f s\n', time_calib_IG_fmincon)

% Calibration via lsqnonlin
flag = 0; % flag variable to calibrate via lsqnonlin

% Start the timer for the calibration time
tic
% Run the calibration
[p_opt_IG_lsq, err] = ...
    calibrationArithmetic(S_p, m, n, F_params, ...
    prices, t, T1, T2, flag, objFunc1, objFunc2);
time_calib_IG_lsq = toc; % stop the timer

% Build a table to display the calibrated parameters
p_opt_Table_IG_lsq = table(p_opt_IG_lsq(1), p_opt_IG_lsq(2), p_opt_IG_lsq(3), p_opt_IG_lsq(4), p_opt_IG_lsq(5), p_opt_IG_lsq(6), p_opt_IG_lsq(7), err,...
    'VariableNames',{'A', 'B', 'C', 'β_1', 'β_2', 'η_1', 'η_2', 'Calibration Error (squared norm 2)'},'RowNames',{'m=p=0, n=2 via lsqnonlin'});
% Display the calibrated parameters
fprintf('\n')
disp('==========================================================================================================================================')
disp('                                  CALIBRATED PARAMETERS m=p=0 n=2 via lsqnonlin')
disp('==========================================================================================================================================')
disp(p_opt_Table_IG_lsq);

% Metrics to evaluate the goodness of the calibration
% Compute the metrics and store them in a table
MetricsTableY_lsq = evaluateMetrics(p_opt_IG_lsq, F_params, prices, T1, T2, m, n, ones(1,m), ones(1,n));
MetricsTableY_lsq.Properties.RowNames = {'m=p=0, n=2 via lsqnonlin'};

% Display the metrics
disp('==========================================================================================================================================')
disp('                                             Metrics to evaluate the goodness of the calibration')
disp('==========================================================================================================================================')
disp(MetricsTableY_lsq);

% Display the time needed for calibration
fprintf('\nTime needed for the calibration via lsqnonlin: %f s\n', time_calib_IG_lsq)

% From now on the parameters obtained via lsqnonlin are considered for
% better interpretability of the model.

%% Simulation of m=p=0 n=2 to price the Put Options
% Extract the parameters
s = p_opt_IG_lsq(1:3);     % Seasonality parameters
n = 2;          % Number of Y processes
beta = p_opt_IG_lsq(4:5);  % Mean reversion speeds for Y
eta = p_opt_IG_lsq(6:7);   % Long-term means for Y processes
k = [1,1];      % Inverse Gaussian parameters

% Set the simulation dates
% starting date of the simulation
today = datetime('4-Nov-2024', 'InputFormat', 'd-MMM-yyyy');
% Simulating for 2 years
T = 2;
% Time to the start of the delivery
T1 = yearfrac(today,'29-Dec-2027',0);
% Time to the settlement
T2 = yearfrac(today,'29-Dec-2028',0);
% Time step for daily simulation assuming 252 trading days per year
dt = 1/252;

% Number of simulations
N_sim = 1e2;

% Simulate the Futures prices
[~,~,~,F] = ...
    simulationArithmetic(N_sim,T,dt,T1,T2,...
    s,[],0,[],[],[1,1],n,beta,eta,k);
% Display the mean and the confidence interval of the simulated Futures prices
fprintf('\nSimulated price of Future: %f\n', round(mean(F),2));
[~,~,CI] = normfit(F);
fprintf('\nCI: %f - %f\n\n',CI(1),CI(2));

% Define strike prices for options
K = 100:10:300;
% Calculate the option prices based on the simulated Futures prices
Calls_IG = mean(max(F-K,0));   % Call option prices
Puts_IG = mean(max(K-F,0));    % Put option prices

% Display the obtained put options via a Table
OptionPricesTable_IG = table(K', Calls_IG', Puts_IG', ...
    'VariableNames', {'Strike Prices', 'Call Prices', 'Put Prices'});
disp(OptionPricesTable_IG);

% Plot the Put and Call option prices against strike prices
figure;
plot(K,Puts_IG,'LineWidth',2)
hold on;
plot(K,Calls_IG,'LineWidth',2)
legend('Puts', 'Calls', 'Location','best');
xlabel('Strikes')
ylabel('Option Price')
title('Puts - Calls IG, Arithmetic model with m=p=0 ,n=2')


%% Arithmetic model based on a Gaussian OU model
disp('==========================================================================================================================================')
disp('                                           Arithmetic Model with m=p=1 n=0')
disp('==========================================================================================================================================')

%% Calibration m=p=1 n=0
% Number of X processes
m = 1;
% Number of Y processes
n = 0;
% Number of parameters for seasonality
S_p = 3;

% Time variables
t = 0;             % Current time
T1 = ttd;          % Time to delivery
T2 = ttd + tenors; % Time to settlement

% Choosing Objective Functions
objFunc1 = @(p, F_params, prices, T1, T2, m, n, X_t, Y_t) ...
    MSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);
objFunc2 = @(p, F_params, prices, T1, T2, m, n, X_t, Y_t) ...
    MSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Start timer for calibration
tic

% Calibration via lsqnonlin
[p_opt_G, err] = ...
    calibrationArithmetic(S_p,m, n, F_params, ...
    prices, t, T1, T2);
time_calib_G = toc; % stop timer for calibration

% Build a table to display the calibrated parameters
p_opt_Table_G = table(p_opt_G(1), p_opt_G(2), p_opt_G(3), p_opt_G(4), err,...
    'VariableNames',{'A', 'B', 'C', 'α', 'Calibration Error (MSE)'},'RowNames',{'m=p=1, n=0'});
% Display the calibrated parameters
disp('==========================================================================================================================================')
disp('                              CALIBRATED PARAMETERS with m=p=1 n=0')
disp('==========================================================================================================================================')
disp(p_opt_Table_G);

% Metrics to evaluate the goodness of the calibration
% Compute the metrics and store them in a table
MetricsTableX = evaluateMetrics(p_opt_G, F_params, prices, T1, T2, m, n, ones(1,m), ones(1,n));
MetricsTableX.Properties.RowNames = {'m=p=1, n=0'};
% Merge the table with the table built above
MetricsTable = vertcat(MetricsTableY_lsq, MetricsTableX);

% Display the metrics for the two calibrations
disp('==========================================================================================================================================')
disp('                                             Metrics to evaluate the goodness of the calibration')
disp('==========================================================================================================================================')
disp(MetricsTable);

% Display the time needed for calibration
fprintf('\nTime needed for the calibration: %f s\n', time_calib_G)
%% Simulation of m=p=1 n=0 to price the Put Options
% Extract the parameters
s = p_opt_G(1:3);     % Seasonality parameters
m = 1;          % Number of X processes
alpha = p_opt_G(end); % Mean reversion speeds for X
sigma = 1;      % Volatility for X

% Set the simulation dates
% starting date of the simulation
today = datetime('4-Nov-2024', 'InputFormat', 'd-MMM-yyyy');
% Simulating for 2 years
T = 2;
% Time to the start of the delivery
T1 = yearfrac(today,'29-Dec-2027',0);
% Time to the settlement
T2 = yearfrac(today,'29-Dec-2028',0);
% Time step for daily simulation assuming 252 trading days per year
dt = 1/252;

% Number of simulations
N_sim = 1e4;

% Simulate the Futures prices
[~,~,~,F] = ...
    simulationArithmetic(N_sim,T,dt,T1,T2,...
    s,1,1,alpha,sigma,[],0,[],[],[]);
% Display the mean and the confidence interval of the simulated Futures prices
fprintf('\nSimulated price of Future: %f\n', mean(F));
[~,~,CI] = normfit(F);
fprintf('\nCI: %f - %f\n\n',CI(1),CI(2));

% Define strike prices for options
K = 100:10:300;
% Calculate the option prices based on the simulated Futures prices
Calls_G = mean(max(F-K,0));   % Call option prices
Puts_G = mean(max(K-F,0));    % Put option prices

% Display the obtained put options via a Table
OptionPricesTable_G = table(K', Calls_G', Puts_G', ...
    'VariableNames', {'Strike Prices', 'Call Prices', 'Put Prices'});
disp(OptionPricesTable_G);

% Plot the Put and Call option prices against strike prices
figure;
plot(K,Puts_G,'LineWidth',2)
hold on;
plot(K,Calls_G,'LineWidth',2)
legend('Puts', 'Calls', 'Location','best');
xlabel('Strikes')
ylabel('Option Price')
title('Puts - Calls Normal, Arithmetic model with m=p=1, n=0')

%% Display Results m=p=0 n=2
% Time variables
t = 0;             % Current time
T1 = ttd;          % Time to delivery
T2 = ttd + tenors; % Time to settlement

% Compute the prices
prices1 = arrayfun(@(j) F_params(0,T1(j),T2(j),p_opt_IG_lsq,0,2,[],[1,1]),1:20);
prices2 = arrayfun(@(j) F_params(0,T1(j),T2(j),p_opt_IG_fmincon,0,2,[],[1,1]),1:20);

% Title for the plot
tiltePlot = 'Calibration Results IG - Arithmetic model with m=p=0, n=2';

% Plot the results
displayResults(prices1',T1,T2,prices,names,tiltePlot)
% displayResults([prices1' prices2'],T1,T2,prices,names,tiltePlot)

%% Display Results m=p=1 n=0
% Compute the prices
prices3= arrayfun(@(j) F_params(0,T1(j),T2(j),p_opt_G,1,0,1,[]),1:20);

% Title for the plot
tiltePlot = 'Calibration Results G - Arithmetic model with m=p=1, n=0';

% Plot the results
displayResults(prices3',T1,T2,prices,names,tiltePlot)

%% Compare the two models
% Title for the plot
% tiltePlot = 'Comparison between IG and G';
% Plot the results
% displayResults([prices1' prices3'],T1,T2,prices,names,tiltePlot)

