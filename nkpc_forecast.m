% forecasting
%% Housekeeping
% clear;
% close all;
% clc;
% iris.startup;
%% Load Solved Model and Historical Database
load mat-file/filter_hist_data.mat f
load mat-file/read_data.mat d startHist endHist
load mat-file/estimate_nkpc_params.mat mest
%% Define Dates
startFcst = endHist + 1;
endFcst = startFcst + 3*4;
startPlot = startFcst - 12;
plotRng = startPlot:endFcst;
highRng = startPlot:endHist;
%% Define Graphics Styles
sty1 = struct( );
sty1.Line.Color = @first;
sty1.Line.LineStyle = {'-', '--', '--'};
sty1.Line.LineWidth = 1.5;
sty1.Line.Marker = {'.', 'none', 'none'};
sty1.Axes.FontSize = 7;
sty1.Legend.FontSize = 7;

sty2 = sty1;
sty2.Line.color = repmat( {@first, @second}, 1, 3);
sty2.Line.LineStyle = {'-', '-', '--', '--', '--', '--'};
sty2.Line.LineWidth = 1.5;
sty2.Line.Marker = {'.', '.', 'none', 'none', 'none', 'none'};
sty2.Axes.FontSize = 7;
sty2.Legend.FontSize = 7;
%% Unconditional Forecast
u = jforecast(mest, f, startFcst:endFcst);
u
u.mean
u.mean = dboverlay(f.mean, u.mean);
u.std = dboverlay(f.std, u.std);
plotList1 = { ...
    ' "Output Gap, Q/Q PA" [mean.Y, mean.Y+std.Y, mean.Y-std.Y]',
    ' "Inflation, Q/Q PA" [mean.Infl, mean.Infl+std.Infl, mean.Infl-std.Infl]',
    ' "Overnight Rate" [mean.R, mean.R+std.R, mean.R-std.R]'};
plotList2 = { ...
	' "Cost Push shocks" mean.u', ...
    ' "Demand shocks" mean.g', ...
    ' "Policy Shocks" mean.e', ...
    };
%% Plot Forecast
dbplot(u, startPlot:endFcst, plotList1, ...
    'Tight=', true, 'Style=', sty1, 'Highlight=', highRng);
grfun.ftitle('Unconditional Forecasts');
grfun.bottomlegend('Mean', 'Mean +/- 1 Std');

dbplot(u, startPlot:endFcst, plotList2, ...
    'Tight=', true, 'Style=', sty1, 'Highlight=', highRng, ...
    'Transform=', @(x) 100*x);
grfun.ftitle('Unconditional Forecasts');
%% Exogenise Interest Rates
sc1 = plan(mest, startFcst:endFcst);
sc1 = exogenize(sc1, 'R', startFcst:startFcst+3);
sc1 = endogenize(sc1, 'e', startFcst:startFcst+3);

f1 = f;
f1.mean.R(startFcst:startFcst+3, 1) = f.mean.R(endHist);

detail(sc1, f1);

j1 = jforecast(mest, f1, startFcst:endFcst, 'Plan=', sc1);
%% Compare Anticipated Conditional Forecasts with Unconditional Forecasts

dbplot(u & j1, startPlot:endFcst, plotList1, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng);
grfun.ftitle('Unconditional vs Exogenized Interest Rate');
grfun.bottomlegend('Uncond Mean', 'Exogen Mean', ...
    'Uncond Mean +/- 1 Std', 'Exogen Mean +/- 1 Std');

dbplot(u & j1, startPlot:endFcst, plotList2, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng, ...
    'Transform=', @(x) 100*x);
grfun.ftitle('Unconditional vs Exogenized Interest Rate');
%% Condition on Anticipated Interest Rates
mest1 = mest;
mest1.std_e = 0;

get(mest, 'Std') & get(mest1, 'Std') %#ok<NOPTS>

sc2 = plan(mest1, startFcst:endFcst);
sc2 = condition(sc2, 'R', startFcst:startFcst+3);

f2 = f;
f2.mean.R(startFcst:startFcst+5) = f2.mean.R(endHist);

c = struct();
c.R = f2.mean.R;

detail(sc2, f2);

j2 = jforecast(mest1, f2, startFcst:endFcst, 'Plan=', sc2);
%% Compare Anticipated Conditional Forecasts with Unconditional Forecasts
dbplot(u & j2, startPlot:endFcst, plotList1, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng);
grfun.ftitle('Unconditional vs Conditional on Anticipated Overnight Rate');
grfun.bottomlegend('Uncond Mean', 'Cond Mean', ...
    'Uncond Mean +/- 1 Std', 'Cond Mean +/ 1 Std');

dbplot(u & j2, startPlot:endFcst, plotList2, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng, ...
    'Transform=', @(x) 100*x);
grfun.ftitle('Unconditional vs Conditional on Anticipated Interest Rate');
%% Condition on Unanticipated Interest Rates
sc3 = sc2;
f3 = f2;

j3 = jforecast(mest1, f3, startFcst:endFcst+50, ...
    'Plan=', sc3, 'anticipate=', false);
%% Compare Unanticipated Conditional Forecasts with Uncondtional Forecasts
dbplot(u & j3, startPlot:endFcst, plotList1, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng);
grfun.ftitle('Unconditional vs Conditional on Unanticipated Overnight Rate');
grfun.bottomlegend('Uncond Mean', 'Cond Mean', ...
    'Uncond Mean +/- 1 Std', 'Cond Mean +/ 1 Std');

dbplot(u & j3, startPlot:endFcst, plotList2, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng, ...
    'Transform=', @(x) 100*x);
grfun.ftitle('Unconditional vs Conditional on Unanticipated Overnight Rate');
%% Exogenised Interest Rates and Condition on Inflation

sc4 = plan(mest, startFcst:endFcst);

sc4 = exogenise(sc4, 'R', startFcst:startFcst+3);
sc4 = endogenise(sc4, 'e', startFcst:startFcst+3);

sc4 = condition(sc4, 'Infl', startFcst:startFcst+3);

f4 = f;
f4.mean.R(startFcst:startFcst+3) = f4.mean.R(endHist);
f4.mean.Infl(startFcst:startFcst+3) = f4.mean.Infl(endHist);

j4 = jforecast(mest1, f4, startFcst:endFcst+50, 'Plan=', sc4);
%% Verify Exogenised and Conditioned Data Points

disp('Interest rate forecast and tunes');
[j4.mean.R{startFcst:startFcst+3}, ...
    f4.mean.R{startFcst:startFcst+3}] %#ok<NOPTS>

disp('Inflation forecast and conditions');
[j4.mean.Infl{startFcst:startFcst+3}, ...
    f4.mean.Infl{startFcst:startFcst+3}] %#ok<NOPTS>
%% Compare Exogenised/Conditional Forecasts with Unconditional Forecasts
dbplot(u & j4, startPlot:endFcst, plotList1, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng);
grfun.ftitle(['Unconditional vs ', ...
    'Anticipated Exogenised Overnight Rate and Conditional on Inflation']);
grfun.bottomlegend('Uncond Mean', 'Cond Mean', ...
    'Uncond Mean +/- 1 Std', 'Cond Mean +/ 1 Std');

dbplot(u & j4, startPlot:endFcst, plotList2, ...
    'Tight=', true, 'Style=', sty2, 'Highlight=', highRng, ...
    'Transform=', @(x) 100*x);
grfun.ftitle(['Unconditional vs ', ...
    'Anticipated Exogenised Short Rate and Conditional on Inflation']);
%% Resimulate Point Forecasts
s1 = simulate(mest1, j1.mean, startFcst:endFcst);
s2 = simulate(mest1, j2.mean, startFcst:endFcst);
s3 = simulate(mest1, j3.mean, startFcst:endFcst, 'anticipate=', false);
s4 = simulate(mest1, j4.mean, startFcst:endFcst);

maxabs(s1, j1.mean) ...
    & maxabs(s2, j2.mean) ...
    & maxabs(s3, j3.mean) ...
    & maxabs(s4, j4.mean) %#ok<NOPTS>
%% Show Variables and Objects Created in This File
whos