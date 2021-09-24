% FILENAME: ptbReadReconInputs
%
% PURPOSE: Read in recon inputs from files
%
% INPUTS:
%   generalParams: general parameters structure
%   filenames:     a structure contains all the file names 
%   reconParams:   recon parameters structure
%   sinoParams:    parameters describing sinograms 
%   corrParams:    correction parameters for recon
%
% OUTPUTS:
%   reconData
%   keyholeData
%   psfMatrix
%
%	Note keyholeData is keyholeImage for TOF recon, keyholeSino for nonTOF recon
%   Default values are used if correction option is NONE.
%
% Copyright 2019 General Electric Company.  All rights reserved.
