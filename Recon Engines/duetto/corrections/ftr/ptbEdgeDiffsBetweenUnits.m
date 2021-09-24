% FILE NAME: ptbEdgeDiffsBetweenUnits.m
%
% This function takes a device map as input and computes the difference 
% between units based on the counts in the device closest to each edge
%
% INPUTS:
%       dm:  device map
%       scanner: Structure that includes geometry information and other factors
%       uNorm: normalized unit map (can be left empty for internal calculation)
%       lambda: lambda parameter
%
% OUTPUTS:
%       ed: edge diffence
%
% USAGE: edgeTemp = ptbEdgeDiffsBetweenUnits(tempDM, scanner, [], params.edge_diff_lambda);
%
% Copyright 2018 General Electric Company. All rights reserved.
