function [y, T, residual, g1] = static_41(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+log(y(47)))/(1+x(34)+(1-params(8))*x(36)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/y(47)/(1+x(34)+(1-params(8))*x(36));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
