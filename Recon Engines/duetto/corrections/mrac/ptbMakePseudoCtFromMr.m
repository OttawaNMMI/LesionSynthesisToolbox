% FILENAME: ptbMakePseudoCtFromMr
%
% PURPOSE: This function computes is a wrapper for ptbMr2PseudoCt.m.
%          It groups the image slices within a bed by anatomy type, 
%          then calls ptbMr2PseudoCt for each of those groups independently,
%          then merges the outputs into 1 dicom series
%
% INPUTS:
%   generalParams: Structure with generalParams
%   mracParams:    Structure obtained from reconParams.MRAC
%   mracStruct:    Structure defining lava_flex directory structure
%   kFrame:        Index of current PET station
%
% OUTPUTS:
%   chunks:  Structure array, with each element corresponding to a PCT chunk
%            from the current PET station. The structure includes:
%              .startSliceNumber - from MRAC series
%              .endSliceNumber - from MRAC series
%              .anatomyName - "Head", "Lungs", "Abdomen", or "Pelvis"
%              .data - 3D data
%              .z - vector of z-axis sample points for data
%              .x - vector of x-axis sample points for data
%              .y - vector of y-axis sample points for data
%   percentPhaseFov: PercentPhaseFieldOfView from MR Dicom headers. (Used
%                    subsequently as a trigger for the "lungFill" step.)
%
% Copyright (c) 2018 General Electric Company. All rights reserved.
