function [t_num, u_count, g_count, u_names_count, g_names_count] = parse_time_users_guests(date, time, users, guests, period)

  t_num   = zeros(0, 1);
  u_count = zeros(0, 1);
  g_count = zeros(0, 1);

  u_names_count = zeros(0, 1);
  g_names_count = zeros(0, 1);

  last_date = date(period(1));
  u_names = {};
  g_names = {};

  for i = 1:size(time, 1)

    if (any(i == period) == 0)
      continue;
    endif

    if (last_date != date(i))

      [u_names_count, g_names_count] = save_result_users_guests(
        last_date,
        date(i),
        u_names,
        g_names,
        u_names_count,
        g_names_count);

      last_date = date(i);
      u_names = {};
      g_names = {};
    endif

    u = strsplit(users{i},  ', ');
    g = strsplit(guests{i}, ', ');

    u_c = 0;
    for j=1:size(u, 2)

      a = u{j} == ' ';
      if ((size(a, 1) == 0 | all(a)) == 0)
        u_c++;
        u_names(1, end+1) = u{j};
      endif

    endfor
    u_count(end + 1, 1) = u_c;

    g_c = 0;
    for j=1:size(g, 2)

      a = g{j} == ' ';
      if ((size(a, 1) == 0 | all(a)) == 0)
        g_c++;
        g_names(1, end+1) = g{j};
      endif

    endfor
    g_count(end + 1, 1) = g_c;

    t = strsplit(time{i}, ' ');

    T = t{1}; % hour:minute
    P = t{2}; % AM/PM

    T = strsplit(T, ':');

    t1 = T{1}; % hour
    t2 = T{2}; % minute
    t3 = 1;    % +hours

    if ((strcmp(P,  'AM') == 1) & (strcmp(t1, '12') == 1))
      t1 = '0';
    endif

    if ((strcmp(P,  'PM') == 1) & (strcmp(t1, '12') == 0))
      t3 -= 0.5;
    endif

    str = sprintf('1.1.0000 %s:%s', t1, t2);

    t_num(end + 1, 1) = datenum(str, 'mm.dd.yyyy HH:MM')-t3;
  endfor

  [u_names_count, g_names_count] = save_result_users_guests(
    last_date,
    date(period(end)),
    u_names,
    g_names,
    u_names_count,
    g_names_count);

endfunction


function [u_names_count, g_names_count] = save_result_users_guests(last_date, date, u_names, g_names, u_names_count, g_names_count)

  names = {};
  c = 0;
  u = 0;

  if (size(u_names, 2) > 0)
    names = unique(u_names);
    u = size(names, 2);
  endif

  if (size(g_names, 2) > 0)
    g_names = unique(g_names);
    s = size(g_names, 2);
    names(1, end+1:end+s) = g_names;
  endif

  if (size(names, 2) > 0)
    c = size(unique(names), 2);
  endif

  u_names_count(end + 1, 1) = u;
  g_names_count(end + 1, 1) = c - u;

  s = date - last_date - 1;

  if (s > 0)
    u_names_count(end+1:end+s, 1) = zeros(s, 1);
    g_names_count(end+1:end+s, 1) = zeros(s, 1);
  endif

endfunction




