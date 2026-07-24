function [y, T, residual, g1] = static_131(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(56))/(1+params(51)+x(20)+x(21)+x(28)*y(13)*x(27)/y(31)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+params(51)+x(20)+x(21)+x(28)*y(13)*x(27)/y(31));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
