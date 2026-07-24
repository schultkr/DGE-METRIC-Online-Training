function [y, T, residual, g1] = static_13(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=(y(360))-(y(360)*params(26)+params(359)*(1-params(26)));
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1-params(26);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
