%
% FILE NAME: osem2dRecon.m
%
% Filtered 2D OSEM Reconstruction
%
% INPUTS:
%       emSino: 2D emission sinogram
%       multCorrSino: 2D multiplicative correction sinogram (CTAC and normDeadtime)
%       addCorrSino: 2D additive correction sinogram (scatter and randoms)
%       scanner: Structure defining the scanner geometry and other factors
%                Obtained from petrecon_scanner.m
%       imParams: parameters for output image
%       reconParams: structure with the following parameters
%          nIterations, nSubsets, fwdProjFunc, backProjFunc
%
% OUTPUTS:
%       reconImage: Reconstructed image
