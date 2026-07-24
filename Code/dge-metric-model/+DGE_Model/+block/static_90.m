function [y, T, residual, g1] = static_90(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(33)=1+x(294)*params(475)*exp(x(295))+(1-x(294))*params(474);
  residual(1)=((1+x(294)*y(22)+y(23)*(1-x(294)))/T(33))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(1-x(294))/T(33);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
