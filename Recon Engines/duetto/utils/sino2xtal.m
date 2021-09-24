%FILE NAME: sino2xtal.m
%
%DEVELOPER: Chuck Stearns   27 Feb 1992
%
%PURPOSE: Compute crystal indices (returned in 2-element
% 	integer array) for the (r,th) location in the sinogram.  
%
%  NOTE:Results are given on the range [0,Nx-1], per the standard
%       numbering convention for crystals, meaning that a user must
%       add "1" before using this as an index into a MATLAB array.
%
% 	Chuck's standard disclaimer: This program was written to support my 
% 	research needs, and not as product code.  Therefore, while I have some 
% 	confidence that it performs its intended function, all permutations of 
% 	options and error conditions have NOT rigorously tested.  The program
% 	is available within GEMS on an "as is" basis.
%
%                                             numbering convention.
% INPUTS:   
%           r            - "r" sinogram sampling index (starting at 0)
%           th           - "theta" sinogram sampling index (starting at 0)
%           sinogramSize - Either:
%                           (a) a 2d sinogram matrix (numberRow, numberPhi)
%                        OR (b) vector of 2d sinogram size
%
% OUTPUTS:
%           x            - Crystal Index (r,th), indexed starting at 0   
