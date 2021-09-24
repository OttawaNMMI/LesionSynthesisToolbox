% FILENAME: ptbSinogramRadCoords.m
%
% PURPOSE: This program computes the radial position of sinogram elements per
%  the detector model described in "Improved Radial Repositioning..."
%  by C. W Stearns (ASL Technical Report 92-54).  Optionally produces
%  the crystal-crystal boundary positions (needed by the native geometry
%  projectors.
%
% INPUTS:
%   nu          Number of sinogram row elements
%   nXtals      Number of crystals per block
%   alpha       Inter-crystal pitch angle (radians)
%   beta        Inter-blockpitch angle (radians)
%   ringDia     Ring diameter
%
% OUTPUTS:
%   rn          Sinogram position array (nXtals-by-nu)
%   bounds      Sinogram element boundary array (nXtals-by-(nu+1))
%
% Note that projectors such as tof*DD3D require the transpose of the
% bounds array
%
% Copyright 2019 General Electric Company. All rights reserved.
