%% Execute Files
% This file executes all of the .mat files for the NKPC model.
%% Housekeeping
clear;
close all;
clc;
iris.startup;
%% Read and Solve the model
% Solves the model and finds the steady state.
run('nkpc_model.m');
%% Import CSV file and read data
% Read the data. For calculating the output gap, HP filter is used on the
% log of GDP, expenditures-based. All of the data are in quarterly
% frequency.
run('read_data.m');
%% Estimate Parameters
% Estimate the parameters using Bayesian methods.
run('estimate_nkpc_params.m');
%% Kalman Filtering and Historical Simulations
% Run the Kalman filter on the historical data to back out unobservable
% variables (such as the productivity process) and shocks, and perform a
% number of analytical exercises that help understand the inner workings of
% the model.
run('filter_hist_data.m');
%% %% Forecasts with Judgmental Adjustments
%
% Use the Kalman filtered data as the starting point for forecasts, both
% unconditional and conditional, i.e. with various types of judgmental
% adjustments.
run('nkpc_forecast.m');