% FILE NAME: ptbCreateFtrMask.m
%
% Creates FTR mask in sinogram domain based on the detector unit number.
%
% INPUTS:
%       units:     detector units who's LOR in ftrMask will be set to zero
%       scanner:   Structure defining the scanner geometry and other factors
%                  Obtained from petrecon_scanner.m
%       acqParams: Structure defining projPlane dimension
%                  Obtained from petrecon_acqParams.m
%
% OUTPUTS:
%       FTRmask:   FTR mask
%
% Copyright 2018 General Electric Company. All rights reserved.
