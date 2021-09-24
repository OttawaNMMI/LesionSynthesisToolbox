
% FILE NAME: ptbCalcSingleScatter.m
%
% DEVELOPER:  Hua Qian
%
% PURPOSE:  This is a wrapper function for the core 3D single scatter
% simulation.  It accepts down emission and attenuation images and returns
% estimated scatter sinograms. This function is an alternative to the
% CalcScatterSino3D.m
%
%	Inputs:
%       dsEmisImg:      Down-sampled emission image
%		dsMuImg:        Down-sampled mu (attenuation co-efficients) image
%       dsMuImgPaths:   Look-up table of line integrals from each
%                       down-sampled mu image voxel to each detector in the
%                       down-sampled ring [nX, nY, nZ, nRadialCrystals,
%                       nAxialCrystals], typically [32, 32, 4, 64, 4].
%       scanner:        scanner structure genenerated from petrecon_scanner
%       scatterParams:  An instance of PtbScatterParams, which has the
%                       following parameters 
%		  dsSinoParams: dsSinoParams structure generated in petrecon3d_scatter3d
%                       contains parameters for down-sampled sinograms
%		  dsImParams:   dsImParams structure generated in petrecon3d_scatter3d
%                       contains parameters for down-sampled image
%         detEffMap:    detector energy efficiency look up table (412 x 41)
%                       with 412 energy bins and 41 Phi bins.
