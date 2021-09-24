% FILENAME: ptbSinoDownSample
%
% PURPOSE: downsample sinogram
% 
% INPUTS:
%   sinoRadRebin   : radially repositioned sinogram (full dimensions)
%   scanner        : scanner parameters
%   dsSinoParams   : down-sampled sinogram parameters
%   dsMethod       : method options described in subSample1D
%
% OUTPUTS:
%   dsSinoRadRebin : downsampled sinogram in 4D sino format
%   dsBinsRadRebin : radially repositioned bin locations in mm
%   dsBins         : native geometry bin locations in mm
%
% NOTE: We assume the input sinogram have values close to zero near the edge.
% To down sample CTAC, please use -log(ctac), i.e. the pathlength.
%
% Copyright 2019 General Electric Company. All rights reserved.
