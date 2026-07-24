function [y, T, residual, g1] = static_117(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(884)=1+y(89)*y(61)/y(434)+y(166)*y(138)/y(434)+y(236)*y(208)/y(434)+y(313)*y(285)/y(434)+y(390)*y(362)/y(434);
  residual(1)=((1+y(406))/T(884))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/T(884);
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
