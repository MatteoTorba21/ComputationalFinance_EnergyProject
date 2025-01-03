function theta = Theta_FWD(t,T,beta,eta,n)
% Function that calculates the Theta in the Forward price expression in the 
% Arithmetic model as in Proposition 4.10 of "Stochastic Modelling of 
% electricity and related markets" by  F. E. Benth, J. S. Benth and S. 
% Koekebakker.
%
% INPUTS:
% t:        Current time
% T:        Maturity
% beta:     Jump part mean reversion speed
% eta:      Intensity of the Jump processes
% n:        Number of Jump processes
%
% OUTPUT:
% theta:    Theta function value

theta = sum(arrayfun(@(i)...
    eta(i) / beta(i) * (1 - exp(-beta(i) * (T-t))), 1:n));

end

