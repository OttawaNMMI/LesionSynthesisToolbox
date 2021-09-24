% FILENAME: ptbCreateRebinningMatrix
%
% PURPOSE: This function creates a matrix that converts from an original
% sampling scheme to a new sampling scheme. This will move around data to
% the appropriate bins, while preserving the sum (to the extent that the
% outer boundaries match up).
% 
% INPUTS:
%   boundsOrig - Boundaries of the original signal. The length of this is the
%           number of original sample points + 1.
%   boundsNew - Boundaries of the resampled signal. The length of this is the
%           number of new sample points + 1.
%
% OUTPUT:
%   weightMat - Matrix to transform sampling. The size is:
%           (resampled # sample points) x (original # sample points)
%
% Copyright 2019 General Electric Company. All rights reserved.
