function [y, T, residual, g1] = dynamic_120(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(735))/(1+params(282)+x(193)+x(194)+x(201)*y(468)*x(200)/y(710)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+params(282)+x(193)+x(194)+x(201)*y(468)*x(200)/y(710));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
