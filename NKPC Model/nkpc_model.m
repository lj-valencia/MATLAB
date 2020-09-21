%% Model
% This file reads and solves the model. 
%% Housekeeping
% clear;
% close all;
% clc;
% iris.startup;
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

m.R_ = 0;
m.Infl_ = 0;
m.Y_ = 0;

disp('Parameter Databank from Model Object:')
get(m, 'parameters') % double check assigned parametrisation
%% Find steady-state and make sure it is a valid steady-state
m = sstate(m);
S = get(m,'sstate'); disp(S); % display steady state level
chksstate(m);
%% Solve the model
m = solve(m);
disp(m)
%% Save model object
save mat-file/nkpc_model.mat m
%% Show variables and objects created in this file
whos
