% FILENAME: ptbSsrb.m
%
% PURPOSE: Perform single slice rebinning (SSRB)
%
% INPUTS::
%         data3d:  3D sinogram data (dimention: nu * nv * nphi)
%           numZ:  the target # of slices
%     numTheta: span # of theta angles 
%
% OUTPUTS::
%        data2d:  rebinned 2D sinogram (dimension: nu * nphi * numZ)
% 
%
% Copyright 2019 General Electric Company. All rights reserved.
