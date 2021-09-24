% FILE NAME: ptbDetectBadUnits.m
%
% This function analyzes a singles map to identify outlying elements, intended
% for use with fault tolerant reconstruction (FTR).
%
% INPUTS:
%       crystalMap:  Singles crystal map
%       scanner:     Structure that includes geometry information and other factors
%
% OPTIONAL INPUTS:
%       inputParams: A structure with fields as defined within ftrParams.m. Note
%                    that any fields omitted from inputParams will use the
%                    values defined within ftrParams.m.
%       plotTitle:   Title of the crystal map plot
%       plotIt:      If true, plot results
%
% OUTPUTS:
%       badUnits: logical matrix indicating location of bad units
%       intermediateResults: intermediate results used for debugging
%       it: number of iterations used during iterative search for outliers 
%
% EXAMPLES:
%
%       Example 1, basic usage default ftrParams and no debug info:
%            badUnitsMap = detectBadUnits(rdfHdr.singles', scanner, ftrParams);
%
%       Example 2, using default ftrParams, with plot:
%           [badUnits, intermediateResults, it] = detectBadUnits( ...
%               rdfHdr.singles', scanner, ftrParams, [], 'Debug Results', true);
%
%       Example 3, using partially defined ftrParams:
%           ftrParams.detrend_lambda = 7;
%           [badUnits, intermediateResults, it] = detectBadUnits( ...
%               rdfHdr.singles', scanner, ftrParams, inputParams, 'Lam=7', true);
%
% Copyright 2018 General Electric Company. All rights reserved.
