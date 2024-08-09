function [count, avg_count, f] = plot_game(figure_number, y1_text, y2_text, short_name, long_name, columns, database, date_start, date_end, smooth_step)

  request = sprintf('SELECT Date, %s, %s FROM GameSessions WHERE Game=''%s''', columns{:}, short_name);
  data    = struct(fetch(database, request));

  Date   = datenum(data._data{1}, 'mm.dd.yyyy');
  period = find((Date >= date_start) & (Date <= date_end));
  Date   = Date(period) - date_start + 1;

  Count   = [data._data{2}{period}]';
  Players = [data._data{3}{period}]';

  s1 = date_end - date_start + 1;
  s2 = size(Date, 1);

  count   = zeros(s1, 1);
  players = zeros(s1, 1);

  for i=1:s2
    j = Date(i);

    count(j)   = Count(i);
    players(j) = Players(i);
  endfor

  [AVG, months] = avg_stats([count, players], date_start, smooth_step);

  avg_count   = AVG(:, 1);
  avg_players = AVG(:, 2);

  players     ./= max(count, 1);
  avg_players ./= max(avg_count, 1);

  date_start_text = datestr(date_start, 'mm.dd.yyyy');
  date_end_text   = datestr(date_end,   'mm.dd.yyyy');

  x = 1:s1;

  long_name = sprintf('%s: статистика за период от %s до %s',
    long_name,
    date_start_text,
    date_end_text);

  x_text = 'Дни';
  f = figure_number;

  plot_stats(f++, x, count,   avg_count,   long_name, x_text, y1_text, months);
  plot_stats(f++, x, players, avg_players, long_name, x_text, y2_text, months);

endfunction
