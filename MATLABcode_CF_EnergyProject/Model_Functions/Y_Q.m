function Y_q = Y_Q(Y_t,t,beta,eta)
% Function that calculates the change of measure for the jump component.
%
% INPUTS:
% Y_t:      Current Y
% t:        Current time
% beta:     Jump part mean reversion speed
% eta:      Instensity of the Jump processes
%
% OUTPUT:
%Y_Q:       Change of measure for jump component

Y_q = Y_t - eta/beta * (1-exp(-beta*t));

end

