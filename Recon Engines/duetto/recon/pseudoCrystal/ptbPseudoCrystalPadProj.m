% FILENAME: ptbPseudoCrystalPadProj.m
%
% PURPOSE: This function converts between the "standard" (native geometry)
% and pseudoCrystal sinograms, and generates the associated scanner and
% acqParams structures
%
% INPUTS:
%     inProj: sinogram to be converted
%     scanner: standard sinogram scanner structure
%     acqParams: standard sinogram acqParams structure
%     padFlag: 1: convert std -> pseudoXtal; 0: convert pseudoXtal -> std
%
% OUTPUTS:
%     outProj: converted sinogram
%     padScanner: scanner structure for pseudoXtal sinogram
%     padAcqParams: acqParams structure for pseudoXtal sinogram
%
% Syntax: 
%     [outProj, padScanner, padAcqParams] = pseudoXtalRebinProj(...
%          inProj, scanner, acqParams, padFlag, padValue)
%
% Copyright 2018 General Electric Company. All rights reserved.
%
%   History:
%   Developers: R. Manjeshwar, H. Qian (Oct 2013)
