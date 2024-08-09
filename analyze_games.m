% pkg install -forge sqlite
% https://github.com/gnu-octave/octave-sqlite/
pkg load sqlite;

warning('off', 'all');
database = sqlite('Stats.sqlite', 'readonly');




%
% GAME SESSIONS
%
date_start = datenum('5.1.2022',  'mm.dd.yyyy');
date_end   = datenum('8.7.2024', 'mm.dd.yyyy');

smooth_step = 7;
figure_step = 3;

f = plot_games(1,
  'Количество игровых сессий',
  'Среднее количество игроков на одну игровую сессию',
  {'Count', 'Players'},
  database,
  date_start,
  date_end,
  smooth_step,
  figure_step,
  0);




%
% GAMES POPULARITY
%
date_start = datenum('4.27.2024', 'mm.dd.yyyy'); % обработка результатов началась с 27 апреля 2024 года
date_end   = datenum('8.7.2024', 'mm.dd.yyyy');

smooth_step = 7;
figure_step = 5;

plot_games(f,
  'Количество поигравших юзеров',
  'Среднее количество игровых сессий на одного юзера',
  {'Users', 'UsersCount'},
  database,
  date_start,
  date_end,
  smooth_step,
  figure_step,
  1);




if (isopen(database) == 1)
  close(database)
endif

