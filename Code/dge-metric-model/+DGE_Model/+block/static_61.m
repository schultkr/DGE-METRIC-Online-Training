function [y, T, residual, g1] = static_61(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+log(y(192)))/(1+x(140)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/y(192)/(1+x(140));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
