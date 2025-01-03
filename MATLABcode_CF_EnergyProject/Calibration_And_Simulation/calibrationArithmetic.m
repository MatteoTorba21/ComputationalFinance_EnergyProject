function [p_opt, err] = calibrationArithmetic(S_p, m, n,...
    F_params, prices, t, T1, T2, flag, objFunc1, objFunc2)
% Function to calibrate an Arithmetic Model.
% A first step of calibration is conducted by minimizing the Obective 
% Function in objFunc1 to find the seasonality parameters initial point; 
% the result of this calibration is used as the starting point for the 
% calibration that minimizes the Obective Function in objFunc2.
%
% INPUTS:
% S_p           Number of seasonality parameters
% m:            Number of X (Gaussian driven) processes
% n:            Number of Y (Inverse Gaussian driven) processes
% F_params:     Parametrized Future Price model function handle
% prices:       Observed market prices
% t:            Current time
% T1:           Delivery start date
% T2:           Settlement date
% flag:         Falg variable
%               - flag == 0 => use lsqnonlin to solve the optimization
%               problem
%               - flag == 1 => use fmincon to solve the optimization
%               problem
% objFunc1:     Objective function to find the initial seasonality
%               parameters
% objFunc2:     Objective function to find the calibrated parameters
%
% OUTPUTS:
% p_opt:        Calibrated parameters  
% err           Error in the objective function

%% Automatic set of the flag variable if not in input
if nargin < 9
    flag = 0;
end

%% Parameters
% Seasonality term
s0 = zeros(1,S_p);          % Initialization of seasonality parameters
lb_s = -inf * ones(1,S_p);  % Lower bound for seasonality parameters
ub_s = -1*lb_s;             % Upper bound for seasonality parameters

% Gaussian driven term X
alpha = ones(1,m);          % Initialization of mean reversion speeds for X
% sigma = ones(1,m); model doesn't depend on sigma during calibration
lb_m = zeros(1,m);          % Lower bound for X parameters
ub_m = inf * ones(1, m);    % Upper bound for X parameters

% Jump part Y
beta = ones(1,n);           % Initialization of mean reversion speeds for Y
eta = ones(1,n);            % Initialization of intensity for Y
% k = ones(1,n); Model doesn't depend on k during calibration
lb_n = zeros(1,2*n);        % Lower bound for Y parameters
ub_n = inf * ones(1,2*n);   % Upper bound for Y parameters

% Starting point and bounds
p0 = [s0 alpha beta eta];
lb = [lb_s lb_m lb_n];
ub = [ub_s ub_m ub_n];

% Initial conditions
X_t = ones(1,m);
Y_t = ones(1,n);

%% Objective Functions
% Parametrized objective function to find the initial seasonality parameters
obj1 = @(p) objFunc1(p, F_params, prices, T1, T2, m, n, X_t, Y_t);
% Parametrized objective function to find the calibrated parameters
obj2 = @(p) objFunc2(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

%% Calibration via lsqnonlin
if ~flag
    % Aeq and beq for constrained seasonality fit
    Aeq = [zeros(m+2*n,S_p) eye(m+2*n)];
    beq = 2.5*ones(m+2*n,1);
    
    % Calibration options
    options = optimoptions('lsqnonlin', ...
            'MaxFunctionEvaluations', 1e10, 'MaxIterations', 1e5, 'Display', 'off');


    % Function to be optimized
    fun = @(p) (arrayfun(@(i) F_params(0,T1(i),T2(i),p,m,n,X_t,Y_t)-prices(i),...
       1:length(T1))');
    
    % First step of calibration to find the seasonality parameters initial point
    [p_start, ~] = lsqnonlin(fun,p0,lb,ub,[],[],Aeq,beq,[],options);
       
    % Second step of calibration to find the parameters
    [p_opt, err] = lsqnonlin(fun,p_start,lb,ub,[],[],[],[],[],options);

end

%% Calibration via fmincon
if flag
    % Aeq and beq for constrained seasonality fit
    Aeq = [zeros(m+2*n,S_p) eye(m+2*n)];
    beq = 2.5*ones(m+2*n,1);
    
    % Calibration options
    options = optimoptions('fmincon', 'Algorithm', 'interior-point', ...
        'MaxFunctionEvaluations', 1e10,'MaxIterations',1e5, 'Display', 'off');
    
    % First step of calibration to find the seasonality parameters initial point
    [p_start, ~] = fmincon(obj1,p0,[],[],Aeq,beq,lb,ub, [],options);   
    
    % Second step of calibration to find the parameters
    [p_opt, err] = fmincon(obj2,p_start,[],[],[],[],lb,ub, [],options);
    
end

end