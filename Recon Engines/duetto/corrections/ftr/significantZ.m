% FILE NAME: significantZ.m
%
% This function finds points with absolute z value greater than sigma. It
% repeats this process iteratively until no more points found. It then
% normalizes the input with the remaining z value mean and standard
% deviation.
%
% INPUTS:
%       map:  z values (2D matrix)
%       sigma: used to eliminate z values greater than this value. default = 3
%
% OUTPUTS:
%       z: normalized map of z values using values from non-outliers
%
% USAGE:
%       zEdgeTemp = significantZ(edgeTemp, params.detect_edge_diff_sig_z, ...
%           params.sig_z_max_iters);
%
% Copyright 2018 General Electric Company. All rights reserved.
