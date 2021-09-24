% FILENAME: ptbScatterTailScaling
%
% PURPOSE:  This function scales estimated scatter sinogram based on a
%           least-squares fit to the tails of the emission data
%
% INPUTS:
%       scatEst:        Estimated scatter sinogram
%       emis3d:         3D emission sinograms
%       sinoTails:      Left and right indices of sinogram tails for each
%                       projection
%                       Dimensions: (2 acqParams.nV acqParams.nPhi)
%       sinoParams:     Structure with sinogram information
%       total_slices:   Number of slices to perform the tail-fit on.
%                       Typically only 2D tail fit is performed on all but
%                       the last iteration of MBSC
%       ftrParams       Structure with FTR information
%       mbscParams:     Structure with model-based scatter parameters
%
% OUTPUTS:
%       scatEst:      Tail-scaled scatter sinogram
%       tailFactors:  Tail-scaling factors
%       slFlags:      Flags indicate lower and upper limits are apllied.
%
% Copyright 2018 General Electric Company. All rights reserved.
