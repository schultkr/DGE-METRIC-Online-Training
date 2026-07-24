function [y, T, residual, g1] = static_105(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(434))/(1+y(362)+y(285)+y(208)+y(61)+y(138)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+y(362)+y(285)+y(208)+y(61)+y(138));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
