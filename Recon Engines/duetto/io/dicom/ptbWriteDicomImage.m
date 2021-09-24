% FILENAME: ptbWriteDicomImage
%
% PURPOSE: Write a set of dicom images from a base reconImg and rawDicomHdr
%
% INPUTS:
%       data:            Floating point 3D image array
%       reconParams:     Structure output from ptbInit
%       generalParams:   Structure output from ptbInit
%       sinoParams:      Structure output from ptbInit
%       frameStats:      Structure output from ptbExtractPetData
%       extraTagsToCopy  Optional; specific additional dicom header fields to copy
%
% OUTPUT:
%       dicom image written to disk
%
% NOTE: ptbPetRecon.m performs reconstruction from inferior to superior.
% However, filesStruct is sorted in order of acquisition.
% Re-sort is important when we want to reconstruct a subset of frames.
%
% Copyright 2020 General Electric Company. All rights reserved.
