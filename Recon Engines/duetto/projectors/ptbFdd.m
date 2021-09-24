% FILENAME: ptbFdd
%
% PURPOSE: ptbFdd is a matlab wrapper function of C mexFdd function.
%
% INPUTS:
%    imageFrame: Object of PtbImage
%    sinoParams: Object of PtbSinogram that has property phiAngles to define subset of view angles.
%    scanner:    Object of PtbScanner
%    tofWeights: Object generated from PtbTofWeightLut2
%
% OUTPUT:
%    projection: Forward-projected sinogram
%
% Copyright 2020 General Electric Company.  All rights reserved.
