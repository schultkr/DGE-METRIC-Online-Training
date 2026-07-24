function [y, T, residual, g1] = static_5(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(6)=1+params(465)*exp(x(308));
  residual(1)=((1+y(428))/T(6))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(6);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
