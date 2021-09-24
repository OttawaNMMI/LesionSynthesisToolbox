% FILENAME: ptbReadDicom
%
% PURPOSE: Read a set of CT, MR or PET DICOM images into a 3d array
%   This function reads a set of DICOM images into a volume. The
%   slices of the volume are index in the filename for the DICOM images
%
% INPUTS
%   filePattern: Filename pattern or directory of the dicom image set.
%                The pattern is passed to matlab's 'dir' function,
%                so can contain a * as wildcards.
%   sortMode   : sort mode for sorting DICOM slices by SliceLocations
%                   default: 'ascend'
%   suvFlag    : If "false" returns native Dicom units of Bq/mL for PET images.
%                If "true" returns SUV units based on Dicom header info.
%                   default: true
%
% OUTPUTS
%   imgData  : output image volume
%   sliceloc : 1d array with slice locations
%   dicomHdr : dicom header as read using ct-dicom-dict.txt,
%       mr-dicom-dict.txt, or pet-dicom-dict.txt depending on the Modality.
%
% SYNTAX
%   [imgData, sliceloc, dicomHdr] = ptbReadDicom(filename_pattern);
%
% Copyright 2018 General Electric Company.  All rights reserved.
