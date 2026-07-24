function [y, T, residual, g1] = dynamic_103(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(882)=exp(y(732));
  residual(1)=((1+y(731))/(1+T(882)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-(T(882)*(1+y(731))))/((1+T(882))*(1+T(882)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
