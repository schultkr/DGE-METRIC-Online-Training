function [y, T, residual, g1] = dynamic_93(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=((1+y(597))/(1+y(619)*y(599)))-(1);
  T(878)=exp(x(90));
  residual(2)=(params(8)*y(599)+(1-params(8))*y(597))-(params(138)*params(469)*(1-params(8))*T(878)+params(8)*((1-x(89))*(params(136)+x(88))+params(469)*T(878)*params(138)/(y(619)+1e-12)*x(89)));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=1/(1+y(619)*y(599));
g1_v(2)=1-params(8);
g1_v(3)=(-(y(619)*(1+y(597))))/((1+y(619)*y(599))*(1+y(619)*y(599)));
g1_v(4)=params(8);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
