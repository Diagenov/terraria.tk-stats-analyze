function [AVG, months] = avg_stats(ORIGINAL, date_start, smooth_step)

  s  = smooth_step;
  s1 = size(ORIGINAL, 1);
  s2 = size(ORIGINAL, 2);

  [y_min, y_max] = get_y_range(ORIGINAL);

  ORIGINAL = min(ORIGINAL, y_max);
  AVG = zeros(s1, s2);

  month_number = [
    12,  1,  2;
     3,  4,  5;
     6,  7,  8;
     9, 10, 11
     ];
  [Y, M, D] = datevec(date_start);
  [i, j] = find(month_number == M);

  month_number = [12, 3, 6, 9];
  months = [i, 1];

  for i=1:s1
    [Y, M, D] = datevec(date_start + i - 1);

    if (D == 1)
      month_index = find(month_number == M);

      if (size(month_index, 2) > 0)
        months(end + 1, :) = [month_index, i];
      endif
    endif

    s_start = i - s;
    s_end   = i + s;

    if (s_start < 1)
      s_start = 1;
    endif

    if (s_end > s1)
      s_end = s1;
    endif

    for k=s_start:s_end
      AVG(i, :) += ORIGINAL(k, :);
    endfor

    AVG(i, :) ./= (s_end - s_start + 1);
  endfor

  months(:, end + 1) = [months(2:end, 2); s1 + 1] - months(:, 2);

endfunction
