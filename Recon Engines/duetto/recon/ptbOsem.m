% FILENAME: ptbOsem
%
% PURPOSE: Image reconstruction using OSEM algorithm
%
% INPUTS
%       initialImg
%       filenames
%       generalParams
%       reconParams
%       sinoParams
%       ftrParams
%       ftrMask (this is within ftrParams, but need to pass in frame-specific)
%       scanner
%
% OUTPUTS
%       reconImg:    Reconstructed image
%       side effect: Recon images at iterations are saved to disk if
%                    reconParams.keepIterationUpdates is set.
%
% Copyright 2018 General Electric Company.  All rights reserved.
