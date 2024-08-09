function plot_week_stats(
    figure_number,
    date_start_text,
    date_end_text,
    quant_mins,
    smooth_step,
    FirstConnect,
    LastConnect,
    floor_FirstConnect,
    floor_LastConnect,
    y_text,
    long_name_format,
    legend)

  date_start = datenum(date_start_text, 'mm.dd.yyyy');
  date_end   = datenum(date_end_text,   'mm.dd.yyyy');

  f = figure_number;
  mins = 1440 / quant_mins;

  week_join  = zeros(mins, 7);
  week_oned  = zeros(mins, 7);
  week_count = zeros(1,    7);

  quant_time = sprintf('1.1.0000 0:%d:0', quant_mins);
  quant_time = datenum(quant_time, 'mm.dd.yyyy HH:MM:SS') - 1;

  for i=date_start:date_end
    wd = weekday(i);
    week_count(wd)++;

    period = find(floor_FirstConnect == i);

    fc = FirstConnect(period);
    lc = LastConnect(period);

    if (size(period, 1) == 0)
      continue;
    endif

    for j=1:mins
      sd = i + (quant_time * (j - 1));
      ed = i + (quant_time * j);

      rd = find((fc >= sd) & (fc < ed));
      od = find(lc(rd) - fc(rd) < 1);

      rd = size(rd, 1);
      od = rd - size(od, 1);

      week_join(j, wd) += rd;
      week_oned(j, wd) += od;
    endfor
  endfor

  week_join ./= week_count;
  week_oned ./= week_count;

  [avg_join, months] = avg_stats(week_join, date_start, smooth_step);
  [avg_oned, months] = avg_stats(week_oned, date_start, smooth_step);

  x = 24 .* (1:mins) ./ mins;
  x_text = 'Часы';

  week_names = {
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    };

  for i=1:7
    long_name = sprintf(long_name_format, week_names{i}, date_start_text, date_end_text);

    ORIG = [ week_join(:, i), week_oned(:, i) ];
    AVG  = [  avg_join(:, i),  avg_oned(:, i) ];

    plot_stats(f++, x, ORIG, AVG, long_name, x_text, y_text, [], legend);
  endfor

  [i, j] = sort(max(avg_join, [], 1));

  j = flip(j);
  y = avg_join(:, j);

  long_name = sprintf(long_name_format, 'Дни недели', date_start_text, date_end_text);

  weeks = {};
  for i=1:7
    weeks{1, end+1} = week_names{j(i)};
  endfor

  plot_stats(f++, x, y, [], long_name, x_text, y_text, [], weeks);

endfunction
