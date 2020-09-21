%% MATLAB Code for Reading the Data
% Written By: LJ Valencia
%% Housekeeping
% clear;
% close all;
% clc;
% iris.startup;
%% Load data(.csv format)
rawQ = databank.fromCSV('quarterly_data.csv',...
    'EnforceFrequency=', Frequency.QUARTERLY,...
    'DateFormat=','YYYY-MM-01');
disp('Raw Quarterly Database')
disp(rawQ)
%% Create Model-Consistent Variable Names
d = struct();
d.Infl = rawQ.CPI_Total; % Canadian CPI Inflation (Total CPI)
Output = rawQ.Cad_GDP; % Canadian GDP (Expenditures-Based) 
d.R = rawQ.Overnight_Rate; % Canadian Overnight Rate

startHist = get(Output, 'Start');
endHist = get(Output, 'End');

disp('Historical range')
(startHist:endHist)' %#ok<NOPTS>
%% Run Plain HP Filters
% d.Infl_tnd = hpf(d.Infl);
Output_tnd = hpf(Output);
d.R_tnd = hpf(d.R);
d.Y = (Output - Output_tnd)*400;
% d.Y_tnd = hpf(d.Y);
%% Plot HP Trends against data
% dbplot(d, Inf,...
%     { ...
%     ' "CPI inflation" [Infl, Infl_tnd]',...
%     ' "Output Gap" [Y, Y_tnd]',...
%     ' "Overnight rate" [R,R_tnd]',...
%     }, ...
%     'Tight=', true);
% grfun.bottomlegend('Data', 'HP Plain');
% grfun.ftitle('Canadian Data for DSGE Modelling');

dbplot(d, Inf,...
    { ...
    ' "CPI inflation" [Infl]',...
    ' "Output Gap" [Y]',...
    ' "Overnight rate" [R,R_tnd]',...
    }, ...
    'Tight=', true);
grfun.bottomlegend('Data', 'HP Plain');
grfun.ftitle('Canadian Data for DSGE Modelling');
%% Save Data for Future Use
save mat-file\read_data.mat d startHist endHist
%% Show Variables and Objects Created In This File
whos
