function [y, T, residual, g1] = dynamic_83(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(34)=1+x(294)*params(475)*exp(x(295))+(1-x(294))*params(474);
  residual(1)=((1+x(294)*y(477)+y(478)*(1-x(294)))/T(34))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(1-x(294))/T(34);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
