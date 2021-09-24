%
% FILE NAME: splineSmooth_m.m
%
% This procedure computes coefficients of cubic splines for a given 
% observational set and smoothing parameter lambda. The method is coded
% according to Pollock D.S.G. (1999), "A Handbook of Time-Series Analysis,
% Signal Processing and Dynamics, Academic Press", San Diego
%
% INPUTS:
%       X:      1D Array (independent variable)
%       Y:      1D Array (function)
%       SIGMA:  1D Array (weight of each measurement). By default
%               all the measurements are of the same weight.
%       LAMBDA: Smoothing parameter (It can be determined empirically, by
%               the LS method or by cross-validation, eg. see book of 
%               Pollock.) LAMBDA equals 0 results in a cubic spline interpolation.
%               In the other extreme, for a very large LAMBDA, the result
%               is smoothing by a linear function.
%       mult:   allows for interpolation between data points in X. For mult equal to:
%                1: no interpolation. returns values at original data points
%                2: interpolates once between data points in X
%                3: interpolates twice between data points in X
%                ...
%  
% OUTPUTS:
%        sc:    Structure of 4 arrays (A, B, C & D) containing the coefficients
%               of a spline between each two of the given measurements.
%
% Syntax: sc = splineSmooth_m(X, Y, SIGM, LAMBDA, mult);
%
% Copyright 2017 General Electric Company. All rights reserved.
