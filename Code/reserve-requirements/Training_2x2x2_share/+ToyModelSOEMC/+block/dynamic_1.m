function [y, T] = dynamic_1(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(39)=params(18)*y(11)+x(1);
  y(41)=x(2)+params(21);
  y(47)=y(39)*y(41);
  y(48)=params(18)*y(20)+x(3);
  y(50)=x(4)+params(24);
  y(56)=y(48)*y(50);
  y(38)=(-y(47))-y(56);
end
