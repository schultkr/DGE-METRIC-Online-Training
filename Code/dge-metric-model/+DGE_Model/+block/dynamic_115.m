function [y, T, residual, g1] = dynamic_115(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(476))/(1+y(870)*y(894)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+y(870)*y(894));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
