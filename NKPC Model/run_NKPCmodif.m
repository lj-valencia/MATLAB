% read and simulate the model
%% Housekeeping
clear;
close all;
clc;
iris.startup;
%% Load model file and create a model object
m = model('NKPC.model');
%% Assign parameters
m.gamma = 0.88;
m.delta = 0.05;
m.fi = 0.11;
m.lambda = -0.63;
m.rho = 0.82;
m.beta_pi = 1.89;
m.beta_y = 0.38;
m.pi_bar = 0.005;
get(m, 'parameters') % double check assigned parametrisation
%% Find steady-state and make sure it is a valid steady-state
m=sstate(m);
S = get(m,'sstate'); disp(S) % display steady state level
chksstate(m);
%% Solve the model
m = solve(m);
disp(m);
%% Create an input database for simulation, enter a shock, and display the
% input time series for the shock on the screen.
d= sstatedb(m,1:40);
randn('state',1000); %1000, 9000
d.u(5) = 0.01;
disp(d.u{1:5});
%% Setting intitial conditions for variables;
d.y(0) = 0.0;
d.pi(0) = m.pi_bar;
d.Epi(0) = m.pi_bar;
d.R(0) = m.pi_bar;
%% Simulate the shock 
s = simulate(m,d,1:40,'deviation=',false,'AppendPresample=', true,'anticipate=',false);
s1 = simulate(m,d,1:40,'deviation=',false,'AppendPresample=', true,'anticipate=',true);
disp(s); disp(s1);

% Plot the simulated paths
sty = struct();
sty.line.linewidth = 1.5;
dbplot(s & s1, 0:40, {'400*y','400*pi','400*R'},'tight=',true,'zeroline=',false,'style=',sty);
legend('unanticipated','anticipated')
grfun.ftitle('Shock Simulation (Cost-Push Shock)');
%% Simulate IRF while holding interest rates fixed for 14 quarters
d.u(1:40) = 0.46*d.u(1:40);
%d.u(11:40) = 0*d.u(11:40);
%d.u(1:5) = -0.01;
p = plan(m,1:40);
p = exogenise(p,'R',1:14);
p = endogenise(p,'e',1:14);
d.R(0:14) = 0.00;
s4 = simulate(m,d,1:40,'deviation=',false, 'AppendPresample=', true,'anticipate=',true);
s5 = simulate(m,d,1:40,'plan=',p,'deviation=',false,'AppendPresample=', true,'maxiter=',1000);
%s5 = dbextend(d,s5);
% Plot the simulated paths
sty = struct();
sty.line.linewidth = 1.5;
dbplot(s4 & s5, 0:40, {'400*y','400*pi','400*R'},'zeroline=',false,'style=',sty);
grfun.ftitle('Simulate IRF: Fixed Interest Rates For 14 Quarters');
%% Monte Carlo experiments
% Simulate time series out of the model. The number of experiments controls
% for the number of realisations that you get for an individual variable.
N = 2; % number of experiments
y = resample(m,[],0:40,N,'method=','montecarlo','progress=',true);
dbplot(y, 0:40, {'400*y','400*pi','400*R'},'zeroline=',false,'style=',sty);
legend('unanticipated','anticipated');
grfun.ftitle('Monte Carlo Simulation');
