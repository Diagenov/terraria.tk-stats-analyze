% pkg install -forge sqlite
% https://github.com/gnu-octave/octave-sqlite/
pkg load sqlite;

warning('off', 'all');
database = sqlite('IPs.sqlite', 'readonly');


date_start = datenum('4.7.2024', 'mm.dd.yyyy'); % новая БД с 7 апреля 2024 года
date_end   = datenum('8.7.2024', 'mm.dd.yyyy');
smooth_step = 7;


request = 'SELECT Country, FirstConnect, LastConnect FROM IPs';
data    = struct(fetch(database, request));

FirstConnect = datenum(data._data{2}, 'yyyy-mm-ddTHH:MM:SS');
LastConnect  = datenum(data._data{3}, 'yyyy-mm-ddTHH:MM:SS');

period = find((FirstConnect >= date_start) & (FirstConnect <= date_end + 1));

FirstConnect = FirstConnect(period);
LastConnect  = LastConnect(period);

floor_FirstConnect = floor(FirstConnect);
floor_LastConnect  = floor(LastConnect);

Country = data._data{1};
country = {};

for i=1:size(Country, 1)
  if (any(i == period) == 1)
    country{end+1, 1} = Country{i};
  endif
endfor

last_date = min([date_start, floor_FirstConnect(1)]);

newIP = zeros(1);
ruIP  = zeros(1);
oneIP = zeros(1);
d05IP = zeros(1);
d15IP = zeros(1);
d30IP = zeros(1);

for i=1:size(floor_FirstConnect, 1)

  fc = floor_FirstConnect(i);
  lc = floor_LastConnect(i);

  if (fc > last_date)
    s = fc - last_date;

    newIP(end+1:end+s, 1) = zeros(s, 1);
    ruIP(end+1:end+s, 1)  = zeros(s, 1);
    oneIP(end+1:end+s, 1) = zeros(s, 1);
    d05IP(end+1:end+s, 1) = zeros(s, 1);
    d15IP(end+1:end+s, 1) = zeros(s, 1);
    d30IP(end+1:end+s, 1) = zeros(s, 1);

    last_date = fc;
  endif

  newIP(end, 1)++;

  if (size(country{i}, 2) == 2 & (country{i} == 'RU' | country{i} == 'UA' | country{i} == 'BY' | country{i} == 'KZ'))
    ruIP(end, 1)++;
  endif

  fc = FirstConnect(i);
  lc = LastConnect(i);

  if (lc - fc < 1)
    oneIP(end, 1)++;

  elseif (lc - fc > 30)
    d30IP(end, 1)++;

  elseif (lc - fc > 15)
    d15IP(end, 1)++;

  elseif (lc - fc > 5)
    d05IP(end, 1)++;
  endif

endfor

if (date_end > last_date)
  s = date_end - last_date;
  newIP(end+1:end+s, 1) = zeros(s, 1);
  ruIP(end+1:end+s, 1)  = zeros(s, 1);
  oneIP(end+1:end+s, 1) = zeros(s, 1);
  d05IP(end+1:end+s, 1) = zeros(s, 1);
  d15IP(end+1:end+s, 1) = zeros(s, 1);
  d30IP(end+1:end+s, 1) = zeros(s, 1);
endif




%
% NEW ACCOUNTS COUNT
%
x = 1:(date_end - date_start + 1);

ORIG = [
  newIP,...
  ruIP,...
  newIP - oneIP,...
  ];
[AVG, months] = avg_stats(ORIG, date_start, smooth_step);


date_start_text = datestr(date_start, 'mm.dd.yyyy');
date_end_text   = datestr(date_end,   'mm.dd.yyyy');

long_name = sprintf('Новые IP-адреса за период от %s до %s',
  date_start_text,
  date_end_text);

x_text = 'Дни';
y_text = 'Количество IP-адресов';

legend = {
  'Все новые IP-адреса',...
  'IP-адреса RU-сегмента',...
  'IP-адреса не однодневки',...
  };

plot_stats(1, x, ORIG, AVG, long_name, x_text, y_text, months, legend);




%
% NEW ACCOUNTS ACTIVITY/ONLINE
%
ORIG = [
  d05IP,...
  d15IP,...
  d30IP,...
  ];
[AVG, months] = avg_stats(ORIG, date_start, smooth_step);

legend = {
  'Заходили в течение 5 дней',...
  'Заходили в течение 15 дней',...
  'Заходили в течение 30 дней',...
  };

plot_stats(2, x, ORIG, AVG, long_name, x_text, y_text, months, legend);




%
% WEEK DAY ONLINE
%
date_start_text = '7.10.2024';
date_end_text   = '8.7.2024';

quant_mins = 30;
smooth_step = 5;

y_text = 'Усредненное количество новых IP-адресов';
long_name = '%s: почасовой прирост новых IP-адресов за период от %s до %s';

legend = {
  'Все новые IP-адреса',...
  'IP-адреса не однодневки',...
  };

plot_week_stats(
  3,
  date_start_text,
  date_end_text,
  quant_mins,
  smooth_step,
  FirstConnect,
  LastConnect,
  floor_FirstConnect,
  floor_LastConnect,
  y_text,
  long_name,
  legend);


if (isopen(database) == 1)
  close(database)
endif
