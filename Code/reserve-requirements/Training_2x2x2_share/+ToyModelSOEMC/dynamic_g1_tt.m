function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = ToyModelSOEMC.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 11
    T = [T; NaN(11 - size(T, 1), 1)];
end
T(8) = params(2)*getPowerDeriv(y(4),params(5),1);
T(9) = getPowerDeriv(T(3),1/params(5),1);
T(10) = getPowerDeriv(T(3),1/params(5)-1,1);
T(11) = params(4)*getPowerDeriv(y(37),params(5),1);
end
