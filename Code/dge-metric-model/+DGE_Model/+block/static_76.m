function [y, T, residual, g1] = static_76(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(26)=1+exp(x(196))+(params(477)+x(186))*x(189);
  residual(1)=((1+y(254))/T(26))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(26);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
