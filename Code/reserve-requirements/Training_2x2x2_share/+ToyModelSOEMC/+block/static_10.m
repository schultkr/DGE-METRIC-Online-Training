function [y, T] = static_10(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(7)=T(3)*params(1)*params(4)*y(9)^(params(5)-1);
  y(6)=T(3)*params(1)*params(3)*params(9)^(params(5)-1);
end
