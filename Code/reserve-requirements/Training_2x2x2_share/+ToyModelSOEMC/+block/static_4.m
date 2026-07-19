function [y, T] = static_4(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(22)=x(4)+params(24);
  y(28)=y(20)*y(22);
  y(10)=(-y(19))-y(28);
end
