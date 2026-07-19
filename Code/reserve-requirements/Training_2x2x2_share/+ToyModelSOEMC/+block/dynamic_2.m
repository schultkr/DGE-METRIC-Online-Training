function [y, T, residual, g1] = dynamic_2(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(2, 1);
  residual(1)=(y(49))-(min(params(17)*max(0,(-x(4))),y(27)));
  residual(2)=(y(55))-((1-params(11))*y(27)-y(49)+params(11)*params(26)+params(12)*max(0,params(26)-y(27)));
if nargout > 3
    g1_v = NaN(3, 1);
g1_v(1)=1;
g1_v(2)=1;
g1_v(3)=1;
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 2, 2);
end
end
