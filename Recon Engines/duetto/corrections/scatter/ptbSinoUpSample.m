% FILENAME: ptbSinoUpSample
%
% PURPOSE: This function upsamples the scatter estimate from
% CalcScatterSino3D() to full resolution in either 2D or in 3D
%
% INPUTS:
%   dsSino           : Estimated scatter sinogram
%   scanner          : Contains scanner parameters
%   sinoParams       : Contains sinogram parameters
%   dsSinoParams     : Contains parameters for down-sampled sinograms
%   dsImParams       : Contains parameters for down-sampled image
%   rotate           : z-axis roll obtained from rdf header
%   directSlicesFlag : Specify whether 2D or 3D sinogram
%
% OUTPUTS:
%   usSino:         upsampled scatter sinogram
%
% Copyright 2019 General Electric Company. All rights reserved.
