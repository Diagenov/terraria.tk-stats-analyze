function [I] = sort_max(Y)

  s1 = size(Y, 1);
  s2 = size(Y, 2);

  I = zeros(1, s2);

  for k=1:s1

    [y, i] = sort(Y(k, :));

    for j=1:s2
      I(i(j)) += j;
    endfor

  endfor

  [V, I] = sort(I);

endfunction
