function [y, T, residual, g1] = static_112(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(881)=exp(y(200));
  residual(1)=((1+y(199))/(1+T(881)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-(T(881)*(1+y(199))))/((1+T(881))*(1+T(881)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
