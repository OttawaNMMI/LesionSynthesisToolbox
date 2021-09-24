% FILENAME: ptbBdd
%
% PURPOSE: ptbBdd is a matlab wrapper function of C mexBdd function.
%
% INPUTS:
%    sinogram:   Object of PtbSinogram with data, which has property phiAngles to define subset
%    imParams:   Object of PtbImage without data
%    scanner:    Object of PtbScanner
%    tofWeights: Object generated from PtbTofWeightLut2
%
% OUTPUT:
%    image:      Backprojected image matrix
% 
% Copyright 2020 General Electric Company.  All rights reserved.
