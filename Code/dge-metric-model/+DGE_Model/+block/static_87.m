function [y, T, residual, g1] = static_87(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(32)=1+params(467)*exp(x(301)+x(299));
  residual(1)=((1+y(419)+params(429)*(x(302)+x(296)+x(294)+x(303)))/T(32))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(32);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
