% FILENAME: ptbTofOsem
%
% PURPOSE: Image reconstruction using TOF-OSEM algorithm
%
% INPUTS
%       initialImg
%       filenames
%       generalParams
%       reconParams
%       sinoParams
%       ftrParams
%       ftrMask
%       scanner
%       keyholeParams
%
% OUTPUTS
%       reconImg:    Reconstructed image
%       side effect: Recon images at iterations are saved to disk if
%                    reconParams.keepIterationUpdates flag is set.
%
% Copyright 2018 General Electric Company.  All rights reserved.
