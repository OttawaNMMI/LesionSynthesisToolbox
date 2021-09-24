% FILENAME: ptbInsertCtLesion.m
%
% PURPOSE: Modify CT for inserted lesions
%
% INPUTS:
%   ctInput       : A path/directory containing CT DICOM images
%                   or a struct including ctInput.imgData, ctInput.dicomHdr, and ctInput.sliceloc
%                                                   (please see ptbReadDicom for more details)
%   lesionMaskVol : a 3D CT lesion mask or a cell array containing multiple 3D masks
%   lesionCTnum   : Lesion CT number (HU). It can be either one value for all volumes in
%                   lesionMaskVol or a vector containing values for all masks in lesionMaskVol
%   outDcmDir     : Output DICOM directory
%   gField        : DICOM fields with new values (optional)
%
% SYNTAX:
%   ptbInsertCtLesion(ctInput, lesionMaskVol, lesionCTnum, outDcmDir, [, gField]);
%
%
% Copyright 2020 General Electric Company.  All rights reserved.
