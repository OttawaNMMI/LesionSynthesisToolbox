% FILE NAME: ptbMakeMrPifa.m
%
% This function builds the PIFA structure and writes the PIFA file.
%
% INPUTS:
%       pifaData - in PIFA (scanner) coordinate system
%       patientPosition - String such as "HFS", "FFDR", etc.
%       tableLocation - start_location from RPDCinfo
%       chunks - chunks structure (does not require the data portion)
%       anatomyBoundaries - anatomy boundary vector
%       anatomyID - Empty or '-' for phantom; 'H' for head; Else body.
%       frameOfReferenceUID - FrameOfReferenceUID, availabe from PET Raw Dicom
%       tcFlag - Truncation completion flag
%       pifaFov_mm - Generally 600 for PET/MR
%       pifaVersion - 1 (binary) or 2 (HDF5)
%       filename - (optional) - PIFA filename, if desired to write file
%
% OUTPUT:
%       chunks: The blended volume
%       zVol:   Z-axis sample points of the blended volume.
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
