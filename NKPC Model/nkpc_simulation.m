%% Simulation
% This file runs simulations on the model. 
%% Housekeeping
clear;
close all;
clc;
iris.startup;
%% Load model file 
load mat-file/nkpc_model.mat m
%% Input database for cost-push shock simulation:
% This section creates an input database, enters a shock, and displays the input time series for the shock on the screen.
d= sstatedb(m,1:40);
randn('state', 1000); % randn returns normally distributed pseudorandom numbers.
d.u(5) = 0.01; %
disp(d.u{1:5});
%% Set intitial conditions for variables;
d.y(0) = 0.0;
d.pi(0) = m.pi_bar;
d.Epi(0) = m.pi_bar;
d.r(0) = m.pi_bar;
%% Simulate the Shock 
s = simulate(m,d,1:40,'deviation=',false,'AppendPresample=', true,'anticipate=',false);
s1 = simulate(m,d,1:40,'deviation=',false,'AppendPresample=', true,'anticipate=',true);
disp(s); disp(s1);

sty = struct();
sty.line.linewidth = 1.5;
dbplot(s & s1, 0:40, {'400*y','400*pi','400*R'},'tight=',true,'zeroline=',false,'style=',sty);
legend('unanticipated','anticipated')
grfun.ftitle('Shock Simulation (Cost-Push Shock)');
%% Simulate the Shock in Full Levels
d = sstatedb(m,1:40);
d.u(1:5) = 0.01;
s = simulate(m,d,1:40,'AppendPresample=',true);

dbplot(d & s, ...
   'Tight=',true,'Transform=',@(x) 100*(x-1));
grfun.ftitle('Cost Push Shock -- Full Levels');
