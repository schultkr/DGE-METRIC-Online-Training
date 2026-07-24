function [y, T, residual, g1] = dynamic_91(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  T(876)=exp(x(263));
  residual(1)=(params(8)*y(823)+(1-params(8))*y(821))-(params(369)*params(469)*(1-params(8))*T(876)+params(8)*((1-x(262))*(params(367)+x(261))+params(469)*T(876)*params(369)/(y(843)+1e-12)*x(262)));
  residual(2)=((1+y(821))/(1+y(843)*y(823)))-(1);
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=params(8);
g1_v(2)=(-(y(843)*(1+y(821))))/((1+y(843)*y(823))*(1+y(843)*y(823)));
g1_v(3)=1-params(8);
g1_v(4)=1/(1+y(843)*y(823));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
