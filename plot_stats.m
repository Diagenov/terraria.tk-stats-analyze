function plot_stats(figure_number, x, y, avg_y, title_text, x_text, y_text, months, legend)

  x_min = 1;
  x_max = max(x);

  [y_min, y_max] = get_y_range(y);

  y_min = min(y_min);
  y_max = max(y_max);

  if (size(avg_y, 1) > 0)
    y_max = max(y_max, max(avg_y(:)) * 1.08);
  endif

  length_max    = [  1,  2,   5,  10,  15,  20,  30,   60,   90 ];
  length_choose = [ 35, 60, 120, 240, 360, 480, 720, 1440, 1800 ];

  length_index = find(length_choose >= x_max);
  x_length = 90;

  if (size(length_index, 2) > 0)
    x_length = length_max(length_index);
    x_length = min(x_length);
  endif

  length_max    = [  1,  2,   5,  10,  20,   50, 100 ];
  length_choose = [ 25, 50, 120, 240, 480, 1000, 2000 ];

  length_index = find(length_choose >= (y_max - y_min));
  y_length = 50;

  if (size(length_index, 2) > 0)
    y_length = length_max(length_index);
    y_length = min(y_length);
  endif

  x_percent = 0.035;
  y_percent = 0.09;

  if (y_max >= 10)
    x_percent += 0.008;
  endif

  if (y_max >= 100)
    x_percent += 0.008;
  endif

  if (y_max >= 1000)
    x_percent += 0.008;
  endif

  x_xlabel = (x_min + x_max) / 2;
  y_ylabel = (y_min + y_max) / 2;

  y_xlabel = y_min - (y_percent * (y_max - y_min));
  x_ylabel = x_min - (x_percent * (x_max - x_min));

  s = size(months);

  figure(figure_number);
  clf;
  hold on;
  grid on;

  if (s > 1)
    plot_months(s, months, y_min, y_max);
  endif

  plot([x_max, x_max], [y_min, y_max], "color", 'k', "linewidth", 0.5);
  plot([x_min, x_max], [y_max, y_max], "color", 'k', "linewidth", 0.5);

  axis([x_min, x_max, y_min, y_max]);
  xticks(0:x_length:x_max);
  yticks(0:y_length:y_max);

  set(gca, 'fontsize', 18);
  title(title_text, 'fontsize', 28);
  xlabel(x_text, 'fontsize', 21, 'position', [x_xlabel, y_xlabel]);
  ylabel(y_text, 'fontsize', 21, 'position', [x_ylabel, y_ylabel]);

  s = size(y, 2);

  if (s == 1)
    plot(x, y, '--', "color", 'k', "linewidth", 0.6);
    plot(x, avg_y,   "color", 'r', "linewidth", 1.6);
  else
    colors = {
      [1.0, 0.0, 0.0],
      [0.0, 0.0, 1.0],
      [1.0, 0.0, 1.0],
      [0.0, 1.0, 0.0],
      [1.0, 0.6, 0.6],
      [0.6, 0.6, 1.0],
      [1.0, 0.6, 1.0],
      [0.6, 1.0, 0.6],
      [1.0, 0.8, 0.8],
      [0.8, 0.8, 1.0],
      };
    types = {
      'o',
      's',
      'd',
      'p',
      'h',
      '+',
      '*',
      '.',
      'x',
      'v',
      };

    texts = {};
    s_t = size(legend, 2);

    for i=1:s
      if (size(avg_y, 1) > 0)
        plot(x, y(:, i), '--', "color", colors{i}, "linewidth", 0.6);
        plot(x, avg_y(:, i),   "color", colors{i}, "linewidth", 1.6);
      else
        t = types{i};
        [thin_x, thin_y] = x_y_thin(size(x, 2), x, y(:, i), x_max, x_length);

        plot(thin_x, thin_y, t,   "color", colors{i}, "markersize", 3.0);
        plot(thin_x, thin_y, '-', "color", colors{i}, "linewidth",  0.4);
      endif

      texts(1, end+1) = sprintf('{\\color[rgb]{%d %d %d} -\\circ- %s}', colors{i}, legend{i});
    endfor

    x_text = x_min + (0.02 * (x_max - x_min));
    y_text = y_min + (0.90 * (y_max - y_min));

    text(x_text, y_text, strjoin(texts, "\n"),
      "fontsize", 18,
      "interpreter", "tex",
      "backgroundcolor", 'w',
      "edgecolor", 'k',
      "linewidth", 1,
      "margin", 5,
      "horizontalalignment", 'left',
      "verticalalignment", 'top');
  endif

  hold off;

endfunction

function plot_months(s, months, y_min, y_max)

  month_names  = {
    'Зима',
    'Весна',
    'Лето',
    'Осень',
    };
  for i=1:s
    plot([months(i, 2), months(i, 2)], [y_min, y_max], "color", 'k', "linewidth", 0.5);

    x_text_months = months(i, 2) + (0.7 * months(i, 3) / 2);
    y_text_months = y_min + (0.95 * (y_max - y_min));

    text(x_text_months, y_text_months, month_names{months(i, 1)}, 'fontsize', 21);
  endfor

endfunction

function [thin_x, thin_y] = x_y_thin(s, x, y, x_max, x_length)

  count = floor(15 * x_max / x_length);
  c = ceil(s / count);

  thin_x = [];
  thin_y = [];

  if (c < 2)
    thin_x = x;
    thin_y = y;
    return;
  endif

  g_x = 0;
  g_y = 0;
  g = 0;

  for i=1:s

    if (g == c)
      thin_x(end+1) = g_x / g; % брать среднее по x
      thin_y(end+1) = g_y / g; % брать среднее по y
      g_x = g_y = g = 0;
    endif

    g_x += x(i);
    g_y += y(i);
    g++;

  endfor

  if (g > 0)
    thin_x(end+1) = g_x / g;
    thin_y(end+1) = g_y / g;
  endif

endfunction
