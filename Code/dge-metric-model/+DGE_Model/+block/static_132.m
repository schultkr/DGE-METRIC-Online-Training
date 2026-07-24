function [y, T, residual, g1] = static_132(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(885)=1+y(432)*y(61)/(y(24)*y(20))*y(89)+y(432)*y(138)/(y(24)*y(20))*y(166)+y(432)*y(208)/(y(24)*y(20))*y(236)+y(432)*y(285)/(y(24)*y(20))*y(313)+y(432)*y(362)/(y(24)*y(20))*y(390);
  residual(1)=((1+y(14))/T(885))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(885);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
