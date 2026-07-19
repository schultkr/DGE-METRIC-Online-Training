function [residual, T_order, T] = static_resid(y, x, params, T_order, T)
if nargin < 5
    T_order = -1;
    T = NaN(7, 1);
end
[T_order, T] = ToyModelSOEMC.static_resid_tt(y, x, params, T_order, T);
residual = NaN(28, 1);
    residual(1) = (y(11)) - (y(11)*params(18)+x(1));
    residual(2) = (y(12)) - (min(params(17)*max(0,(-x(2))),y(18)));
    residual(3) = (y(13)) - (x(2)+params(21));
    residual(4) = (y(14)) - (y(12)+y(13));
    residual(5) = (y(15)) - (y(14)*T(1));
    residual(6) = (y(17)) - (params(16)*y(1)/2);
    residual(7) = (y(16)) - (y(17)+y(16)*(1-params(15)));
    residual(8) = (y(18)) - (y(18)*(1-params(11))-y(12)+params(11)*params(23)+params(12)*max(0,params(23)-y(18)));
    residual(9) = (y(19)) - (y(11)*y(13));
    residual(10) = (y(20)) - (params(18)*y(20)+x(3));
    residual(11) = (y(21)) - (min(params(17)*max(0,(-x(4))),y(27)));
    residual(12) = (y(22)) - (x(4)+params(24));
    residual(13) = (y(23)) - (y(21)+y(22));
    residual(14) = (y(24)) - (y(23)*T(2));
    residual(15) = (y(26)) - (params(16)*y(1)/2);
    residual(16) = (y(25)) - (y(26)+(1-params(15))*y(25));
    residual(17) = (y(27)) - ((1-params(11))*y(27)-y(21)+params(11)*params(26)+params(12)*max(0,params(26)-y(27)));
    residual(18) = (y(28)) - (y(20)*y(22));
    residual(19) = (y(8)) - (y(15)+y(24));
    residual(20) = (y(9)) - (y(8)+params(10));
    residual(21) = (y(1)) - (params(1)*T(3)^(1/params(5)));
    residual(22) = (y(5)) - (T(4)*T(5));
    residual(23) = (y(6)) - (T(5)*T(6));
    residual(24) = (y(7)) - (T(5)*T(7));
    residual(25) = (y(1)) - (y(28)+y(26)+y(19)+y(17)+y(2)+y(3)+y(18)*params(19)+params(20)*y(18)^2+y(27)*params(19)+params(20)*y(27)^2);
    residual(26) = (y(4)) - (y(3)+y(4)*(1-params(8)));
    residual(27) = (1/y(2)) - (1/y(2)*params(7)*(1+y(5)-params(8)));
    residual(28) = (y(10)) - ((-y(19))-y(28));
end
