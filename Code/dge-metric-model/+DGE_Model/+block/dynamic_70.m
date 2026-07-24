function [y, T, residual, g1] = dynamic_70(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+log(y(803)))/(1+x(265)+(1-params(8))*x(267)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/y(803)/(1+x(265)+(1-params(8))*x(267));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
