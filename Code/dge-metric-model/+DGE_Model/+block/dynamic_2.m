function [y, T, residual, g1] = dynamic_2(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(2)=exp(x(305));
  residual(1)=((1+y(887))/(1+(params(16)==0)*params(451)*T(2)+(params(16)==1)*params(451)*T(2)))-(1);
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=1/(1+(params(16)==0)*params(451)*T(2)+(params(16)==1)*params(451)*T(2));
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
