function [y, T, residual, g1] = dynamic_95(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=((1+y(744))/(1+y(766)*y(746)))-(1);
  T(880)=exp(x(205));
  residual(2)=(params(8)*y(746)+(1-params(8))*y(744))-(params(291)*params(469)*(1-params(8))*T(880)+params(8)*((1-x(204))*(params(289)+x(203))+params(469)*T(880)*params(291)/(y(766)+1e-12)*x(204)));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=(-(y(766)*(1+y(744))))/((1+y(766)*y(746))*(1+y(766)*y(746)));
g1_v(2)=params(8);
g1_v(3)=1/(1+y(766)*y(746));
g1_v(4)=1-params(8);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
