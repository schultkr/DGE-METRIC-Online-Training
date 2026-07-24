function [y, T, residual, g1] = static_58(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(16)=1+exp(x(81))+(params(477)+x(71))*x(74);
  residual(1)=((1+y(107))/T(16))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(16);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
