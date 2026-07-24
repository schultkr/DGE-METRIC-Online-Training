function [y, T, residual, g1] = dynamic_125(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(887)=1+y(887)*y(516)/(y(479)*y(475))*y(544)+y(887)*y(593)/(y(479)*y(475))*y(621)+y(887)*y(663)/(y(479)*y(475))*y(691)+y(887)*y(740)/(y(479)*y(475))*y(768)+y(887)*y(817)/(y(479)*y(475))*y(845);
  residual(1)=((1+y(469))/T(887))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(887);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
