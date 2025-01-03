function f = Forward(t,T,X_t,Y_t,s,alpha,m,beta,eta,n)
% Function that calculates the forward price for a given maturity T
% based on the current time t, and on the parameters of the Arithmetic 
% model as in Proposition 4.10 of "Stochastic Modelling of electricity and
% related markets" by  F. E. Benth, J. S. Benth and S.  Koekebakker.
%
% INPUTS:
% t:        Current time
% T:        Maturity
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
% f:        Forward price

% Add the seasonality function
f = Lambda(T,s);

% Add the Gaussian part
if m > 0
    f = f + sum(cell2mat(arrayfun(@(i) ...
    X_t * exp(-alpha(i) * (T-t)),1:m,'UniformOutput',false)),2);
end

% Add the Jumps part
if n > 0
    f = f + Theta_FWD(t,T,beta,eta,n) + sum(cell2mat(arrayfun(@(i) ...
    Y_Q(Y_t(:,i),T,beta(i),eta(i)) * exp(-beta(i) * (T-t)),1:n,'UniformOutput',false)),2);
end

end

