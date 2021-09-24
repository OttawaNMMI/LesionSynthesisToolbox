% FILE NAME: expandXtalMapToSino.m
%
% PURPOSE:
%   This function expands a crystal map into a full sinogram. This general
%   functionality is used in deadtime, normalization, and randoms from singles
%   processing.
%   The shared cross-plains (+/- 1) are handled differently for the different
%   corrections, and therefore the expansionTypeStr is used to handle these
%   cross-plains.
%
% INPUTS:
%       xtalMap:  This is a 2D matrix of the crystal-based coefficients.
%                 Size: (radial # crystals) x (axial # crystals)
%       nR:       Number of radial samples in the output sinogram
%       expansionTypeStr:  Determines how the cross-plains (+/- 1) are
%                          handled in the expansion of the sinogram:
%                          String options:
%                           'deadtime'
%                           'norm'
%                           'randoms'
%                           'FTR'
%
% OUTPUTS:
%       sino:      Expanded sinogram-based correction coefficients
%                  Datatype: Logical for FTR, otherwise single.
%
% Copyright 2019 General Electric Company. All rights reserved.
