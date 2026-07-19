function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(7, 1);
end
[T_order, T] = ToyModelSOEMC.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(28, 1);
    residual(1) = (y(39)) - (params(18)*y(11)+x(1));
    residual(2) = (y(40)) - (min(params(17)*max(0,(-x(2))),y(18)));
    residual(3) = (y(41)) - (x(2)+params(21));
    residual(4) = (y(42)) - (y(40)+y(41));
    residual(5) = (y(43)) - (y(42)*T(1));
    residual(6) = (y(45)) - (params(16)*y(29)/2);
    residual(7) = (y(44)) - (y(45)+y(16)*(1-params(15)));
    residual(8) = (y(46)) - (y(18)*(1-params(11))-y(40)+params(11)*params(23)+params(12)*max(0,params(23)-y(18)));
    residual(9) = (y(47)) - (y(39)*y(41));
    residual(10) = (y(48)) - (params(18)*y(20)+x(3));
    residual(11) = (y(49)) - (min(params(17)*max(0,(-x(4))),y(27)));
    residual(12) = (y(50)) - (x(4)+params(24));
    residual(13) = (y(51)) - (y(49)+y(50));
    residual(14) = (y(52)) - (y(51)*T(2));
    residual(15) = (y(54)) - (params(16)*y(29)/2);
    residual(16) = (y(53)) - (y(54)+(1-params(15))*y(25));
    residual(17) = (y(55)) - ((1-params(11))*y(27)-y(49)+params(11)*params(26)+params(12)*max(0,params(26)-y(27)));
    residual(18) = (y(56)) - (y(48)*y(50));
    residual(19) = (y(36)) - (y(43)+y(52));
    residual(20) = (y(37)) - (y(36)+params(10));
    residual(21) = (y(29)) - (params(1)*T(3)^(1/params(5)));
    residual(22) = (y(33)) - (T(4)*T(5));
    residual(23) = (y(34)) - (T(5)*T(6));
    residual(24) = (y(35)) - (T(5)*T(7));
    residual(25) = (y(29)) - (y(56)+y(54)+y(47)+y(45)+y(30)+y(31)+y(18)*params(19)+params(20)*y(18)^2+y(27)*params(19)+params(20)*y(27)^2);
    residual(26) = (y(32)) - (y(31)+y(4)*(1-params(8)));
    residual(27) = (1/y(30)) - (params(7)*1/y(58)*(1+y(61)-params(8)));
    residual(28) = (y(38)) - ((-y(47))-y(56));
end
