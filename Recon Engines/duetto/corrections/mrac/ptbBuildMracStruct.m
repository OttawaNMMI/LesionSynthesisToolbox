% FILENAME: ptbBuildMracStruct.m
%
% PURPOSE: This function builds the MRAC_struct for MRAC processing.
%          Create mracStruct and perform sorting of LAVA directories
%
% INPUTS:
%   mracParams     - Includes the "chunks" structure (defined within MR2pseudoCTwrapper)
%   patientEntry   - 0 for head-first; 1 for feet-first
%   anatomyDcmInfo - Anatomy boundary dicom group, passed in as petRawDicomHdr.Private_0023_1017.Item_1.Private_0023_101c
%
% OUTPUT:
%   mracStruct     - Structure with info on LAVA Flex MRAC series
%
% Copyright 2020 General Electric Company. All rights reserved.
