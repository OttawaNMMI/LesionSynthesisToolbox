% FILENAME: ptbSortLavaDirs.m
%
% PURPOSE: This function sorts through DICOM image folders to assign a
%          single DICOM folder to a bed station number
%
% INPUTS:
%    lavaLoc:      Directory location of the DICOM folders
%    lavaType:     Keyword contained in DICOM folder name. Supported
%                  keywords are 'WATER', 'FAT', 'InPhase', 'TOFNAC', and 'pseudoCT'.
%    patientEntry: Patient entry ID as read from RDF (or
%                  acqParams.patientEntry). Either 0 or 1.
%
% OUTPUT:
%    outStruct: Structure containing directory information that is
%               sorted according to the bed station number
%
% SYNTAX:
%   outStruct = ptbSortLavaDirs('MRAC', 'WATER', patientEntry);
%
% Copyright 2018 General Electric Company.  All rights reserved.
