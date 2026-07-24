function [y, T, residual, g1] = static_99(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=((1+y(212))/(1+y(234)*y(214)))-(1);
  T(875)=exp(x(147));
  residual(2)=(params(8)*y(214)+(1-params(8))*y(212))-(params(213)*params(469)*(1-params(8))*T(875)+params(8)*((1-x(146))*(params(211)+x(145))+params(469)*T(875)*params(213)/(y(234)+1e-12)*x(146)));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=1/(1+y(234)*y(214));
g1_v(2)=1-params(8);
g1_v(3)=(-(y(234)*(1+y(212))))/((1+y(234)*y(214))*(1+y(234)*y(214)));
g1_v(4)=params(8);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
