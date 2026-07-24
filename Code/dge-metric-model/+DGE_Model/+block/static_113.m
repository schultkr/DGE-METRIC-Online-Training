function [y, T, residual, g1] = static_113(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(163))/(1+y(162)/y(164)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+y(162)/y(164));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
