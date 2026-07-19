function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 7
    T = [T; NaN(7 - size(T, 1), 1)];
end
T(1) = (y(16)/params(22))^(1-params(14));
T(2) = (y(25)/params(25))^(1-params(14));
T(3) = params(2)*y(4)^params(5)+params(3)*params(9)^params(5)+params(4)*y(9)^params(5);
T(4) = params(1)*params(2)*y(4)^(params(5)-1);
T(5) = T(3)^(1/params(5)-1);
T(6) = params(1)*params(3)*params(9)^(params(5)-1);
T(7) = params(1)*params(4)*y(9)^(params(5)-1);
end
