function [y, T] = static_2(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(13)=x(2)+params(21);
  y(19)=y(11)*y(13);
end
