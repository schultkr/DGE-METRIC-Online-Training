function [y, T, residual, g1] = dynamic_62(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(23)=1+exp(x(199));
  residual(1)=((1+y(725))/T(23))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(23);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
