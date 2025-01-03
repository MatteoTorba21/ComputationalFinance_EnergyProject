function F = Future(t,T1,T2,X_t,Y_t,s,alpha,m,beta,eta,n)
% Function that calculates the Future price for a given delivery date T1
% and settlement date T2, based on the current time t, and on the 
% parameters of the Arithmetic model as in Proposition 4.14 of "Stochastic
% Modelling of electricity and related markets" by  F. E. Benth, J. S. 
% Benth and S.  Koekebakker.
%
% INPUTS:
% t:        Current time
% T1:       Delivery date
% T2:       Settlement date
% X_t:      Current X condition 
% Y_t:      Current Y condition
% s:        Vector containing the three seasonality parameters
% alpha:    Gaussian part mean reversion speed
% m:        Number of Gaussian processes
% beta:     Jump part mean reversion speed
% eta:      Intensity of the Jump processes
% n:        Number of Jump processes
%
% OUTPUT:
% F:        Future price

% Add seasonality part
F = Lambda_Integrated(T1,T2,s);

% Add Gaussian part
if m > 0
    F = F + sum(cell2mat(arrayfun(@(i)...
    X_t(:,i)*(exp(-alpha(i)*(T1-t)) - ...
    exp(-alpha(i)*(T2-t)))/(alpha(i)*(T2-T1)),...
    1:m,'UniformOutput',false)),2);
end

% Add Jumps part
if n > 0 
    F = F + Theta_FUT(t, T1, T2, beta, eta, n) + ...
    sum(cell2mat(arrayfun(@(i)...
    Y_Q(Y_t(:,i),t,beta,eta)*(exp(-beta(i)*(T1-t)) - ...
    exp(-beta(i)*(T2-t)))/(beta(i)*(T2-T1)),...
    1:n,'UniformOutput',false)),2);
end

end
