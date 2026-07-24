function [y, T, residual, g1] = dynamic_122(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(479)*y(475))/(1+y(887)*y(889)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=y(479)/(1+y(887)*y(889));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
