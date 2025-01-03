function err = RMSE(p, F_params, prices, T1, T2, m, n, X_t, Y_t)
% Computes Root Mean Squared Error (RMSE)
% This function calculates the Root Mean Squared Error (RMSE) between the
% Future price values predicted by the Arithmetic model and observed
% market prices.
%
% Parameters:
% p:        Vector of model parameters
% F_params: Function handle for computing forward prices based on the 
%           Arithmetic model
% prices:   Observed market prices
% T1:       Vector of start delivery times
% T2:       Vector of end delivery times (settlements)
% m:        Number of Gaussian processes in the model.
% n:        Number of Jump processes in the model.
% X_t:      Current values of Gaussian processes.
% Y_t:      Current values of Jump processes.
%
% Returns:
% err       The root mean squared error between model-predicted and
%           observed prices

% Calculate the RMSE by iterating over all Future contracts
err = sqrt(MSE(p, F_params, prices, T1, T2,...
    m, n, X_t, Y_t));

end

