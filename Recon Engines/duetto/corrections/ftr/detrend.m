%
% FILE NAME: detrend.m
%
% This function creates a normalized map.
%
% INPUTS:
%       xy:  2D matrix to be de-trended 
%       lambda: smoothing parameter used for detrending. (recommended = 5)
%
% OUTPUTS:
%       DT: normalized (de-trended) map
%       rescale: normalizing factor
%
% USAGE: [DT, rescale] = detrend(xy, lambda);
%
% Copyright 2017 General Electric Company. All rights reserved.
