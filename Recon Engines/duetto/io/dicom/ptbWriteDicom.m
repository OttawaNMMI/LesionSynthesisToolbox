% FILENAME: ptbWriteDicom
%
% PURPOSE: Writes a 3d array into a set of CT, MR, or PET DICOM images.
% This function assumes that the 3d array (imgData), the slice location (sliceloc)
% and dicom header (dicomHdr) are first read from dicom files using readDICOM.m.
%
% INPUTS
%    outDir:        Output directory of the dicom image set.
%    img3d:         Image volume
%    sliceLoc:      1D array with slice locations
%    dicomHdr:      Dicom header obtained using readDICOM.m
%    generalParams: Structure output from ptbInit
%
% Copyright 2019 General Electric Company. All rights reserved.
