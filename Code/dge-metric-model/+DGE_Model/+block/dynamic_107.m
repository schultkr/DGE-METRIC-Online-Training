function [y, T, residual, g1] = dynamic_107(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(884)=exp(y(585));
  residual(1)=((1+y(584))/(1+T(884)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-(T(884)*(1+y(584))))/((1+T(884))*(1+T(884)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
