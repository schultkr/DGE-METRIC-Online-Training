function [y, T, residual, g1] = dynamic_61(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+log(y(726)))/(1+x(207)+(1-params(8))*x(209)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/y(726)/(1+x(207)+(1-params(8))*x(209));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
