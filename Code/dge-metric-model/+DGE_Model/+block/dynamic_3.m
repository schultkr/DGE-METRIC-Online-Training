function [y, T, residual, g1] = dynamic_3(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(3)=1+y(887)+(params(463)-params(451))*exp(x(306));
  residual(1)=((1+y(886))/T(3))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(3);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
