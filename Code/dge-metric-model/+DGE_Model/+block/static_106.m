function [y, T, residual, g1] = static_106(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(420))/(1+y(366)+y(289)+y(212)+y(65)+y(142)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+y(366)+y(289)+y(212)+y(65)+y(142));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
