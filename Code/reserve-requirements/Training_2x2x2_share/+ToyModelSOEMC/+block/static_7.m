function [y, T, residual, g1] = static_7(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=(y(18))-(y(18)*(1-params(11))-y(12)+params(11)*params(23)+params(12)*max(0,params(23)-y(18)));
  residual(2)=(y(12))-(min(params(17)*max(0,(-x(2))),y(18)));
if nargout > 3
    g1_v = NaN(4, 1);
g1_v(1)=1-(1-params(11)+params(12)*(-(1-(0>params(23)-y(18)))));
g1_v(2)=(-(1-(y(18)>params(17)*max(0,(-x(2))))));
g1_v(3)=1;
g1_v(4)=1;
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
