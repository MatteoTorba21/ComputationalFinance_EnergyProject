function theta = Theta_FUT(t,T1,T2,beta,eta,n)
% Function that calculates the Theta in the Future price expression in the 
% Arithmetic model as in Proposition 4.14 of "Stochastic Modelling of 
% electricity and related markets" by  F. E. Benth, J. S. Benth and S. 
% Koekebakker.
%
% INPUTS:
% t:        Current time
% T1:       Delivery date
% T2:       Settlement date
% beta:     Jump part mean reversion speed
% eta:      Intensity of the Jump processes
% n:        Number of Jump processes
%
% OUTPUT:
% theta:    Theta function value

theta = ...
    sum(arrayfun(@(i) ...
    eta(i)/beta(i)^2*(exp(-beta(i)*(T2-t)) - ...
    exp(-beta(i)*(T1-t)) + ...
    beta(i)*(T2-T1)),1:n)) * 1/(T2-T1);

end

