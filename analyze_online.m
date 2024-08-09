% pkg install -forge sqlite
% https://github.com/gnu-octave/octave-sqlite/
pkg load sqlite;

warning('off', 'all');
database = sqlite('Stats.sqlite', 'readonly');


date_start = datenum('10.3.2021', 'mm.dd.yyyy');
date_end   = datenum('8.7.2024', 'mm.dd.yyyy');
smooth_step = 7;


'Обращение к базе данных...'
request = 'SELECT * FROM Online';
data    = struct(fetch(database, request));


'Получение и парсинг данных...'
Date   = datenum(data._data{1}, 'mm.dd.yyyy');
period = find((Date >= date_start) & (Date <= date_end));

[Time, Users, Guests, AllUsers, AllGuests] = parse_time_users_guests(
  Date,
  data._data{2},
  data._data{4},
  data._data{5},
  period
  );
Online = [data._data{3}{period}]';

[Date, period, j] = unique(Date(period) + Time - date_start + 1);

Online = Online(period);
Users  = Users(period);
Guests = Guests(period);

quant_time = 1.0 / 288;

s1 = date_end - date_start + 1;
s2 = size(Date, 1);

online = zeros(s1, 288);
users  = zeros(s1, 288);
guests = zeros(s1, 288);

for i=1:s2
  d = Date(i);
  j = floor(d);
  k = ((d - j) / quant_time) + 1;

  j = uint32(j);
  k = uint32(k);

  online(j, k) = Online(i);
  users(j, k)  = Users(i);
  guests(j, k) = Guests(i);
endfor


'Обработка данных...'
date_start_text = datestr(date_start, 'mm.dd.yyyy');
date_end_text   = datestr(date_end,   'mm.dd.yyyy');

x = 1:s1;
f = 1;
x_text = 'Дни';




%
% MAX ONLINE
%
MAX = [
  max(online, [], 2),...
  max(users,  [], 2),...
  max(guests, [], 2),...
  ];
[AVG, months] = avg_stats(MAX, date_start, smooth_step);

y_text = 'Максимальное количество игроков';
long_name = sprintf('Максимальные показатели онлайна за период от %s до %s',
  date_start_text,
  date_end_text);

plot_stats(f++, x, MAX(:, 1),   AVG(:, 1),   long_name, x_text, y_text, months);
plot_stats(f++, x, MAX(:, 2:3), AVG(:, 2:3), long_name, x_text, y_text, months, {'Юзеры', 'Гости'});




%
% UNIQUE USERS & GUESTS ONLINE
%
ALL = [
  AllUsers + AllGuests,...
  AllUsers,...
  AllGuests,...
  ];
[AVG, months] = avg_stats(ALL, date_start, smooth_step);

y_text = 'Количество посетителей';
long_name = sprintf('Посещаемость сервера за период от %s до %s',
  date_start_text,
  date_end_text);

plot_stats(f++, x, ALL(:, 1),   AVG(:, 1),   long_name, x_text, y_text, months);
plot_stats(f++, x, ALL(:, 2:3), AVG(:, 2:3), long_name, x_text, y_text, months, {'Юзеры', 'Гости'});




%
% WEEK DAY ONLINE
%
date_start_text = '7.10.2024';
date_end_text   = '8.7.2024';

date_start = datenum(date_start_text, 'mm.dd.yyyy');
date_end   = datenum(date_end_text,   'mm.dd.yyyy');

smooth_step = 5;

week_online = zeros(288, 7);
week_users  = zeros(288, 7);
week_guests = zeros(288, 7);

week_count = zeros(1, 7);

for i=1:s1
  wd = weekday(date_start + i - 1);
  week_count(wd)++;

  week_online(:, wd) += online(i, :)';
  week_users(:, wd)  += users(i, :)';
  week_guests(:, wd) += guests(i, :)';
endfor

week_online ./= week_count;
week_users  ./= week_count;
week_guests ./= week_count;

[avg_online, months] = avg_stats(week_online, date_start, smooth_step);
[avg_users,  months] = avg_stats(week_users,  date_start, smooth_step);
[avg_guests, months] = avg_stats(week_guests, date_start, smooth_step);

x = 24 .* (1:288) ./ 288;

y_text = 'Усредненное количество игроков';
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
  long_name = sprintf('%s: почасовой онлайн за период от %s до %s',
    week_names{i},
    date_start_text,
    date_end_text);

  plot_stats(f++, x, week_online(:, i), avg_online(:, i), long_name, x_text, y_text, []);

  ORIG = [ week_users(:, i), week_guests(:, i) ];
  AVG  = [  avg_users(:, i),  avg_guests(:, i) ];

  plot_stats(f++, x, ORIG, AVG, long_name, x_text, y_text, [], {'Юзеры', 'Гости'});
endfor

[i, j] = sort(max(avg_online, [], 1));

j = flip(j);
y = avg_online(:, j);

long_name = sprintf('Дни недели: почасовой онлайн за период от %s до %s',
    date_start_text,
    date_end_text);

weeks = {};
for i=1:7
  weeks{1, end+1} = week_names{j(i)};
endfor

plot_stats(f++, x, y, [], long_name, x_text, y_text, [], weeks);


if (isopen(database) == 1)
  close(database)
endif
