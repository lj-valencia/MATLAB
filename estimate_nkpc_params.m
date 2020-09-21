% estimate parameters
%% Housekeeping
% clear;
% close all;
% clc;
% iris.startup;
%% Load Solved Model and Historical Database
load mat-file/nkpc_model.mat m
load mat-file/read_data.mat d startHist endHist
%% Set Up Estimation Input Structure
estimSpecs = struct();

estimSpecs.gamma = {NaN, 0.01, 0.95, distribution.Normal.fromMeanStd(0.8, 0.15)};
estimSpecs.delta = {NaN, 0.05, 0.5, distribution.Normal.fromMeanStd(0.1, 0.025)};
estimSpecs.fi = {NaN, 0.01, 0.5, distribution.Normal.fromMeanStd(0.5, 0.1)};
estimSpecs.lambda = {NaN, -1, -0.3, distribution.Normal.fromMeanStd(-0.5, 0.05)};
estimSpecs.rho = {NaN, 0.01, 4, distribution.Normal.fromMeanStd(0.8, 1)};
estimSpecs.beta_pi = {NaN, 1.5, 3, distribution.Normal.fromMeanStd(1.89, 0.15)};
estimSpecs.beta_y = {NaN, 0.1, 1.5, distribution.Normal.fromMeanStd(0.38, 0.15)};

% Priors of shocks are based from Milani (2007)
estimSpecs.std_u = {1, 0.34, 2.81, distribution.InvGamma.fromMeanStd(1, Inf)};
estimSpecs.std_g = {1, 0.34, 2.81, distribution.InvGamma.fromMeanStd(1, Inf)};
estimSpecs.std_e = {1, 0.34, 2.81, distribution.InvGamma.fromMeanStd(1, Inf)};

% estimSpecs.gamma = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(0.88, 0.025)};
% estimSpecs.delta = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(0.05, 0.025)};
% estimSpecs.fi = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(0.11, 0.025)};
% estimSpecs.lambda = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(-0.63, 0.025)};
% estimSpecs.rho = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(0.82, 0.025)};
% estimSpecs.beta_pi = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(1.89, 0.025)};
% estimSpecs.beta_y = {NaN, -Inf, Inf, distribution.Normal.fromMeanStd(0.38, 0.025)};
% 
% estimSpecs.std_u = {NaN, -Inf, Inf, distribution.InvGamma.fromMeanStd(0.25, 0.0046)};
% estimSpecs.std_g = {NaN, -Inf, Inf, distribution.InvGamma.fromMeanStd(1, 0.0036)};
% estimSpecs.std_e = {NaN, -Inf, Inf, distribution.InvGamma.fromMeanStd(0.2, 0.0036)};

disp(estimSpecs)
%% Visualize Prior Distributions
c = autocaption(m, estimSpecs, '$descript$');

[~, ~, h] = plotpp(estimSpecs, [ ], [ ], ...
    'Subplot=', [2, 3], 'Caption=', c);

ftitle(h.figure, 'Prior Distributions');
%% Estimation
filterOpt = { ...
    'OutOfLik=', {'R_', 'Infl_', 'Y_'}, ...
    'Relative=', true, ...
    'InitUnit=', 'ApproxDiffuse', ...
    };

optimSet = { ...
    'MaxFunEvals=', 10000, ...
    'MaxIter=', 200, ...
    };
[summary, pos, C, H, mest, v, delta, Pdelta] = ...
    estimate(m, d, startHist:endHist, estimSpecs, ...
    'Summary=', 'Table','OptimSet=',optimSet,'NoSolution=','Penalty','Filter=',filterOpt);
% [summary, pos, C, H, mest, v, delta, Pdelta] = ...
%     estimate(m, d, startHist:endHist, estimSpecs, ...
%     'Summary=', 'Table','OptimSet=',optimSet,'Filter=',filterOpt);
%% Print Some Estimation Results
summary

disp('Common variance factor');
v

disp('Out-of-lik parameters');
delta

disp('Parameters in the estimated model object');
disp('Std deviations adjusted for the common variance factor');
get(mest, 'parameters')
%% Visualize Prior Distributions and Posterior Modes
[pr, po, h] = plotpp(estimSpecs, summary, [ ], ...
    'Title=', {'FontSize=', 8}, ...
    'Axes=', {'FontSize=', 8}, ...
    'PlotInit=', {'Color=', 'red', 'Marker=', '*'}, ...
    'Subplot=', [2, 3]); %#ok<ASGLU>

ftitle(h, 'Prior Distributions and Posterior Modes');
legend('Prior Density', 'Starting Value', 'Posterior Mode', ...
    'Lower Bound', 'Upper Bound');
%% Examine Neighborhood Around Optimum
n = neighbourhood(mest, pos, 0.95:0.005:1.05, ...
    'Progress=', true, 'Plot=', false)

plotneigh(n, 'LinkAxes=', true, 'Subplot=', [2, 3], ...
    'PlotObj=', {'LineWidth=', 2}, ...
    'PlotEst=', {'Marker=', 'o', 'LineWidth=', 2}, ...
    'PlotBounds=', {'LineStyle', '--', 'LineWidth', 2});
%% Run Metropolis Random Walk Posterior Simulator
N = 5000

tic;
[theta, logpost, ar] = arwm(pos, N, ...
    'Progress=', true, 'AdaptScale=', 2, 'AdaptProposalCov=', 1, ...
    'BurnIn=', 0.20);
toc;

disp('Final acceptance ratio');
ar(end)

s = stats(pos, theta, logpost)
%% Visualize Priors and Posteriors
[pr, po, h] = plotpp(estimSpecs, summary, theta, ...
    'PlotPrior=', {'LineStyle=', '--'}, ...
    'Title=', {'FontSize=', 8}, ...
    'Subplot=', [2, 3]);

ftitle(h.figure, 'Prior Distributions and Posterior Distributions');

legend('Prior Density', 'Posterior Mode', 'Posterior Density', ...
    'Lower Bound', 'Upper Bound');
%% Save Model Object With Estimated Parameters
save mat-file/estimate_nkpc_params.mat mest pos estimSpecs