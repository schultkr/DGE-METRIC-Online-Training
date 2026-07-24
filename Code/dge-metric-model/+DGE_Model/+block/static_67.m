function [y, T, residual, g1] = static_67(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(21)=1+exp(x(138))+(params(477)+x(128))*x(131);
  residual(1)=((1+y(177))/T(21))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(21);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
