% FILENAME: subSampleN.m
% 
% PURPOSE: Sub-samples a multi-dimensional matrix.
%
% INPUTS:
%   matrix  - matrix to be subsampled
%   dimsNew - desired output dimensions as a vector. Note: If the length of 
%             dimsNew is shorter than the number of dimensions in "matrix",
%             then the additional dimensions in matrix will be unaffected.
%   method  - OPTIONAL: for description of available sub-sampling methods:
%             help subSample1D
%
% OUTPUT:
%    matrix - subsampled matrix
%
% Copyright 2019 General Electric Company.  All rights reserved.
