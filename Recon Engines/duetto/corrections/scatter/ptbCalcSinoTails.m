% FILENAME: ptbCalcSinoTails
%
% PURPOSE: Estimates the body contour in the attenuation image and determines the
% correcponding left and right indices of sinogram tails for each CTAC projection
%
% INPUTS:
%   acfSino:     attenuation correction sinogram
%	muImg:       attenuation mu image
%   scanner:     
%   pifa:        pifa structure from ptbReadPifa.m (requires header only, no data)
%   mbscParams:  mbscParams structure
%   frameParams: an instance of PtbFramesStats
%
% OUTPUTS:
%   sinoTails:   left and right indices of sinogram tails for each projection
%                   dimensions: (2 acqParams.nV acqParams.nPhi)
%   emisMask:    binary volume with patient mask
%
% Copyright 2020 General Electric Company.  All rights reserved.
