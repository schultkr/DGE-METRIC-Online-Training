function [y, T, residual, g1] = dynamic_42(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(12)=1+exp(x(23))+(params(477)+x(13))*x(16);
  residual(1)=((1+y(485))/T(12))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(12);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
