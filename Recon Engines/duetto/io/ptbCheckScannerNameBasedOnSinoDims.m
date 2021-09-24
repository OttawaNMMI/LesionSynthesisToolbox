% FILENAME: ptbCheckScannerNameBasedOnSinoDims.m
%
% PURPOSE: Check that the scanner name matches up with sinogram dimensions
% we expect.  This is circular logic for scanner data, as we get both the
% name and sinogram dimensions from thh data, but it might be a helpful
% check in other situations, e.g. simulated data.
%
% INPUTS:
%    inputScannerName : This name is compared against the scanner to which
%                       the sinogram dimensions refer
%    nU
%    nV
%    nPhi
%
% OUTPUTS:
%    warning if scanner name does not match sinogram dimensions
%
% Copyright 2018 General Electric Company.  All rights reserved.
