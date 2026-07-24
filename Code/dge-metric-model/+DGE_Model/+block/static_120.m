function [y, T, residual, g1] = static_120(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(12))/(1+max(0,y(32)*y(34))+max(0,y(109)*y(111))+max(0,y(179)*y(181))+max(0,y(256)*y(258))+max(0,y(333)*y(335))))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+max(0,y(32)*y(34))+max(0,y(109)*y(111))+max(0,y(179)*y(181))+max(0,y(256)*y(258))+max(0,y(333)*y(335)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
