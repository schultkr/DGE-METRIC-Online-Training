function [y, T, residual, g1] = static_73(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(23)=1+params(280)*exp(x(219));
  residual(1)=((1+y(257)+params(429)*(x(214)+x(182)))/T(23))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(23);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
