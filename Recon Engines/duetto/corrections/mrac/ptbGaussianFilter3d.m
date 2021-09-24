% FILENAME: ptbGaussianFilter3d.m
% 
% PURPOSE: This function implements 3D Gaussian filtering.  It is assumed that X and Y
% are the same pixel spacing, while Z can be different pixel spacing.
% 
% INPUTS:
%    img:         A 3D image volume
%    FWHMxy:      The FWHM in X & Y   (consistent units with the other inputs)
%    FWHMz:       The FWHM in Z       (consistent units with the other inputs)
%    pixelSizeXY: Pixel size in X & Y (consistent units with the other inputs)
%    pixelSizeZ:  Pixel size in Z     (consistent units with the other inputs)
%    sigmaCutoff: [Optional] - cutoff in units of sigma (standard deviation),
%                     default is 4 if unspecified
% 
% OUTPUT:
%    img:         The filtered volume
% 
% Copyright (c) 2020 General Electric Company. All rights reserved.
