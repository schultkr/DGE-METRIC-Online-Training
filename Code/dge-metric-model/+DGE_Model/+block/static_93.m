function [y, T, residual, g1] = static_93(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(449))/(1+y(449)*(1-params(20))+y(448)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(1+y(449)*(1-params(20))+y(448)-(1-params(20))*(1+y(449)))/((1+y(449)*(1-params(20))+y(448))*(1+y(449)*(1-params(20))+y(448)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
