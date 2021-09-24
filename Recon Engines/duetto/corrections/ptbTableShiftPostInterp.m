% FILENAME: tablePostInterpolation.m
%
% PURPOSE: This function post-interpolates the reconImg to account for the
% mis-alignment between two adjacent PET frames
%
% INPUTS:
%    reconParams    : Structure defining reconstruction parameters
%    padReconParams : Structure defining parameters for padded/keyhole image
%    scanner:       : Structure defining scanner geometry and other factors
%    reconImg:      : Image to be interpolated
%
% OUTPUT
%    reconImg       : Interpolated image
%
% Copyright 2019 General Electric Company.  All rights reserved.
