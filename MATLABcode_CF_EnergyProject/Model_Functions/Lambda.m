function L = Lambda(t,p)
% Seasonality Function.
%
% INPUTS:
% t:    Time
% p:    Vector containing the three seasonality parameters
%
% OUTPUT:
% L:    Computed Seasonality function

L = p(1) * sin(2*pi*t) + p(2) + p(3) * t;

end

