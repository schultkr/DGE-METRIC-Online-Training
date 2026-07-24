function [y, T, residual, g1] = static_130(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(133))/(1+params(129)+x(78)+x(79)+x(86)*y(13)*x(85)/y(108)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+params(129)+x(78)+x(79)+x(86)*y(13)*x(85)/y(108));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
