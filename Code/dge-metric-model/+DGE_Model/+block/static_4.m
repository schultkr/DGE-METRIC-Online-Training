function [y, T, residual, g1] = static_4(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(4)=exp(x(2));
  T(5)=1+1/(params(422)*T(4))-1+x(1)+params(425);
  residual(1)=((1+y(10))/T(5))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(5);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
