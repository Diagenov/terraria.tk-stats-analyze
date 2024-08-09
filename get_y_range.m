function [Y_min, Y_max] = get_y_range(Y)

  s2 = size(Y, 2);

  Y_max = zeros(1, s2);
  Y_min = zeros(1, s2);

  for i=1:s2
    y = Y(:, i);
    p = find(y > 0);
    y = y(p(1):end);

    s = size(y, 1);
    c = int32(s * 0.05);
    c = max(5, c);

    y_min = min(y);
    y -= y_min;

    for k=1:c
      [y_max, j] = max(y);

      C = find(y / y_max < 0.6);

      if (size(C, 1) / s < 0.9)
        break;
      endif

      y(j) = y_min;
    endfor

    Y_max(i) = y_max + y_min;
    Y_min(i) = y_min;
  endfor

endfunction
