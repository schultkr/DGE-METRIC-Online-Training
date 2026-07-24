function [y, T, residual, g1] = static_56(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(14)=1+exp(x(109));
  residual(1)=((1+y(128))/T(14))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(14);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
