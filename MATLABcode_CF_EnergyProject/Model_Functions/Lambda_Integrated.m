function L_I = Lambda_Integrated(T1,T2,p)
%LAMBDA_INTEGRATED Summary of this function goes here
% Integrated Seasonality Function for the computation of the Future Price.
%
% INPUTS:
% T1:   Delivery date
% T2:   Settlement date
% p:    Vector containing the three seasonality parameters
%
% OUTPUT:
% L_I:  Computed integrated Seasonality function

L_I = 1/(T2-T1) * (p(1)/(2*pi)*(cos(2*pi*T1)-cos(2*pi*T2))+ ...
    p(2)*(T2-T1)+p(3)/2*(T2^2-T1^2));

end

