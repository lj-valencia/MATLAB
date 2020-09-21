% filter historical data
%% Housekeeping
% clear;
% close all;
% clc;
% iris.startup;
%% Load Solved Model and Historical Database
load mat-file/estimate_nkpc_params.mat mest
load mat-file/read_data.mat d startHist endHist
%% Run Kalman Filter
[~, f, v, ~, pe, co] = filter(mest, d, startHist:endHist+10);
%% Plot estimated shocks
list = get(mest, 'elist');

dbplot(f.mean, startHist:endHist, list, ...
    'Tight=', true, 'ZeroLine=', true, 'Transform=', @(x) 100*x);
ftitle('Estimated shocks');

dbplot( ...
    f.mean, startHist:endHist, list, ...
    'Tight=', true, ...
    'ZeroLine=', true, ...
    'PlotFunc=', @hist, ...
    'Title=', get(mest, 'EDescript'), ...
    'Transform=', @(x) 100*x ...
);

ftitle('Histograms of Estimated Transition Shocks');
%% K-Step Ahead Kalman Predictions
k = 8;

[~, g] = filter(mest, d, startHist:endHist, ...
    'Output=', 'Pred, Smooth', 'MeanOnly=', true, 'Ahead=', k);

g %#ok<NOPTS>
g.pred
g.smooth

figure( );
[h1, h2] = plotpred(startHist:endHist, d.R, g.pred.R);
set(h1, 'Marker', '.');
set(h2, 'LineStyle', ':', 'LineWidth', 1.5);
grid on;
title('Overnight Rate: 1- to 5-Qtr-Ahead Kalman Predictions');
%% Resimulate Filtered Data
s = simulate(mest, f.mean, startHist:endHist, 'Anticipate=', false);

dbfun(@(x, y) max(abs(x-y)), f.mean, s)
%% Run Counterfactual
f1 = f.mean;
f1.e(:) = 0;

s1 = simulate(mest, f1, startHist:endHist, 'Anticipate=', false);

figure( );
plot([s.Infl, s1.Infl]);
grid on;
title('Inflation, Q/Q PA');
legend('Actual Data', 'Counterfactual without Cost Push Shocks');
%% Simulate Contribution of Shocks (Inflation)
c = simulate(mest, s, startHist:endHist+8, ...
    'Anticipate=', false, 'Contributions=', true, 'AppendPresample=', true);

c %#ok<NOPTS>
c.Infl
figure( );

subplot(2, 1, 1);
plot(startHist:endHist, [s.Infl, c.Infl{:, end}]);
grid on;
title('Inflation, Q/Q PA');
legend('Actual data', 'Steady State + Init Cond', ...
    'location', 'northWest');

subplot(2, 1, 2);
barcon(startHist:endHist, c.Infl{:, 1:end-2});
grid on;
title('Contributions of shocks');

edescript = get(mest, 'EDescript');
legend(edescript{:}, 'Location', 'NorthWest');
%% Simulate Contribution of Shocks (Output Gap)
c = simulate(mest, s, startHist:endHist+8, ...
    'Anticipate=', false, 'Contributions=', true, 'AppendPresample=', true);

c %#ok<NOPTS>
c.Y
figure( );

subplot(2, 1, 1);
plot(startHist:endHist, [s.Y, c.Y{:, end}]);
grid on;
title('Output Gap, Q/Q PA');
legend('Actual data', 'Steady State + Init Cond', ...
    'location', 'northWest');

subplot(2, 1, 2);
barcon(startHist:endHist, c.Y{:, 1:end-2});
grid on;
title('Contributions of shocks');

edescript = get(mest, 'EDescript');
legend(edescript{:}, 'Location', 'NorthWest');
%% Plot Grouped Contributions
g = grouping(mest, 'Shock', 'IncludeExtras=', true);
g = addgroup(g, 'Demand', 'g');
g = addgroup(g, 'Supply', 'u');

detail(g);

[cg, lg] = eval(g, c);

figure( );

subplot(2, 1, 1);
plot(startHist:endHist, [s.Infl, c.Infl{:, end-1}]);
grid on;
title('Inflation, Q/Q PA');
legend('Actual Data', 'Steady state + Init Cond', ...
    'Location', 'NorthWest');

subplot(2, 1, 2);
conbar(cg.Infl{:, 1:end-1});
grid on;
title('Contributions of Shocks');
legend(lg(:, 1:end-1), 'Location', 'NorthWest');
%% Save File
save mat-file/filter_hist_data.mat f