function [f] = plot_games(figure_number, y1_text, y2_text, columns, database, date_start, date_end, smooth_step, figure_step, use_sort_max)

  short_name = {
    'bmt',
    'race',
    'sumo',
    'murder',
    'dr',
    'sw',
    'hs',
    'ff',
    'hp',
    'oc',
    'gg',
    'fb',
    'bs',
    'chess',
    'checkers',
    'hg',
    'sg',
    'bc',
    'tetris',
    'cw',
    'tw',
    'ctf',
    'pc',
    'dtb',
    };

  long_name = {
    'BMT',
    'Race',
    'Sumo',
    'Murder',
    'DeathRun',
    'SkyWars',
    'HideSeek',
    'FizzleFloor',
    'HotPotato',
    'OneInTheChamber',
    'GunGame',
    'Football',
    'Battleship',
    'Chess',
    'Checkers',
    'HungerGame',
    'SurvivalGame',
    'BattleCity',
    'Tetris',
    'ClassWars',
    'TeamWars',
    'CaptureTheFlag',
    'PointsControl',
    'DefeatTheBoss',
    };

  s1 = date_end - date_start + 1;
  s2 = size(short_name, 1);

  orig = zeros(s1, s2);
  avg  = zeros(s1, s2);

  f = figure_number;

  x_text = 'Дни';
  x = 1:s1;



  %
  % GAME STATS
  %
  for i=1:s2
    [orig_count, avg_count, f] = plot_game(
      f,
      y1_text,
      y2_text,
      short_name{i},
      long_name{i},
      columns,
      database,
      date_start,
      date_end,
      smooth_step);

    orig(:, i) = orig_count;
    avg(:, i)  =  avg_count;
  endfor




  %
  % ALL GAMES STATS
  %
  date_start_text = datestr(date_start, 'mm.dd.yyyy');
  date_end_text   = datestr(date_end,   'mm.dd.yyyy');

  long_name = sprintf('Общая статистика по играм за период от %s до %s',
    date_start_text,
    date_end_text);

  y = sum(orig, 2);

  [avg_orig, months] = avg_stats(y, date_start, smooth_step);
  plot_stats(f++, x, y, avg_orig, long_name, x_text, y1_text, months);




  %
  % CONTRAST GAMES STATS
  %
  long_name = sprintf('Сравнение популярности игр за период от %s до %s',
    date_start_text,
    date_end_text);

  ii = [];
  if (use_sort_max)
    ii = sort_max(avg);
  else
    [vv, ii] = sort(max(avg, [], 1));
  endif
  f_s = figure_step;

  for i=1:ceil(s2 / f_s)

    start_i = (i-1)*f_s + 1;
    end_i   = min(i*f_s, s2);

    jj = ii(start_i:end_i);
    jj = flip(jj);
    tt = {};

    for j=1:size(jj, 2)
      tt(1, end+1) = short_name{jj(j)};
    endfor

    y = avg(:, jj);
    plot_stats(f++, x, y, [], long_name, x_text, y1_text, months, tt);

  endfor

endfunction
