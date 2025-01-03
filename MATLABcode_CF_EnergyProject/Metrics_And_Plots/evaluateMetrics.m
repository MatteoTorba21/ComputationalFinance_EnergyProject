function MetricsTable = evaluateMetrics(p, F_params, prices, T1, T2, m, n, X_t, Y_t)
% Function to compute the error of the calibrated model from the market 
% prices with respect to some Metrics. The metrics considered are: the 
% Cauchy Loss, the Huber Loss, the Log-Cosh Loss, the MAE, the MAPE, the
% MSE, the MSE with Ridge penalty, the RMSE, the Weighted MSE.
%
% INPUTS:
% p:            Calibrated parameters of the model
% F_params:     Parametrized Future Price model function handle
% prices:       Observed market prices
% T1:           Delivery start date
% T2:           Settlement date
% m:            Number of X (Gaussian driven) processes
% n:            Number of Y (Inverse Gaussian driven) processes
% X_t:          X initial condition
% Y_t:          Y initial condition
%
% OUTPUT:
% MetricsTable: Table containing the computed metrics

% Cauchy Loss
model_Cauchy = Cauchy(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Huber Loss
model_Huber = Huber(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Log-Cosh Loss
model_LogCosh = LogCosh(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Mean Absolute Error (MAE)
model_MAE = MAE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Mean Absolute Percentage Error (MAPE)
model_MAPE = MAPE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Mean Square Error (MSE)
model_MSE = MSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Mean Square Error with Ridge penalty (MSE_L2)
model_MSE_L2 = MSE_L2(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Root Mean Square Error (RMSE)
model_RMSE = RMSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Weighted MSE (Weighted by time to maturity)
model_WgtdMSE = WgtdMSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t);

% Create the output table
MetricsTable = table(model_Cauchy, model_Huber, model_LogCosh, model_MAE, model_MAPE,...
    model_MSE, model_MSE_L2, model_RMSE, model_WgtdMSE,...
    'VariableNames', {'Cauchy Loss', 'Huber Loss', 'Log-cosh Loss', 'MAE', 'MAPE', ...
    'MSE', 'MSE_L2', 'RMSE', 'WgtdMSE'});

end