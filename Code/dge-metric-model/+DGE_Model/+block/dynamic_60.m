function [y, T, residual, g1] = dynamic_60(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(22)=1+exp(x(138))+(params(477)+x(128))*x(131);
  residual(1)=((1+y(632))/T(22))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(22);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
