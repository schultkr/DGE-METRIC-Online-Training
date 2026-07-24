function [y, T, residual, g1] = dynamic_110(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(886)=1+y(544)*y(516)/y(889)+y(621)*y(593)/y(889)+y(691)*y(663)/y(889)+y(768)*y(740)/y(889)+y(845)*y(817)/y(889);
  residual(1)=((1+y(861))/T(886))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(886);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
