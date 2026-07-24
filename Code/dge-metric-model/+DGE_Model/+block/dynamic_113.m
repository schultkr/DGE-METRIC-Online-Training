function [y, T, residual, g1] = dynamic_113(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=((1+y(467))/(1+max(0,y(487)*y(489))+max(0,y(564)*y(566))+max(0,y(634)*y(636))+max(0,y(711)*y(713))+max(0,y(788)*y(790))))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+max(0,y(487)*y(489))+max(0,y(564)*y(566))+max(0,y(634)*y(636))+max(0,y(711)*y(713))+max(0,y(788)*y(790)));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
