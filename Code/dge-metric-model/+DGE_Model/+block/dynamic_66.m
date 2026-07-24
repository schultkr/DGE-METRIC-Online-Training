function [y, T, residual, g1] = dynamic_66(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(24)=1+params(280)*exp(x(219));
  residual(1)=((1+y(712)+params(429)*(x(214)+x(182)))/T(24))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(24);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
