function [y, T, residual, g1] = dynamic_29(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(722))/(1+y(721)+(1-params(335))*y(267)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-(1+y(722)))/((1+y(721)+(1-params(335))*y(267))*(1+y(721)+(1-params(335))*y(267)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
