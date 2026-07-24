function [y, T, residual, g1] = dynamic_92(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=((1+y(520))/(1+y(542)*y(522)))-(1);
  T(877)=exp(x(32));
  residual(2)=(params(8)*y(522)+(1-params(8))*y(520))-(params(60)*params(469)*(1-params(8))*T(877)+params(8)*((1-x(31))*(params(58)+x(30))+T(877)*params(469)*params(60)/(y(542)+1e-12)*x(31)));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=(-(y(542)*(1+y(520))))/((1+y(542)*y(522))*(1+y(542)*y(522)));
g1_v(2)=params(8);
g1_v(3)=1/(1+y(542)*y(522));
g1_v(4)=1-params(8);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
