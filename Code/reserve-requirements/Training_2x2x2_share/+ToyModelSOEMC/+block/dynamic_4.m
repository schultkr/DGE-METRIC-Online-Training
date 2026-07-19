function [y, T, residual, g1] = dynamic_4(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=(y(40))-(min(params(17)*max(0,(-x(2))),y(18)));
  residual(2)=(y(46))-(y(18)*(1-params(11))-y(40)+params(11)*params(23)+params(12)*max(0,params(23)-y(18)));
if nargout > 3
    g1_v = NaN(3, 1);
g1_v(1)=1;
g1_v(2)=1;
g1_v(3)=1;
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
