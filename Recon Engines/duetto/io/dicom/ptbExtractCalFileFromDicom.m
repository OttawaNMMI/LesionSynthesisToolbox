% FILENAME: ptbExtractCalFileFromDicom
%
% PURPOSE: This function reads in a DICOM PET RAW data file and writes the
%          embedded RDF or WCC data to disk.
%          It works only with norm, geo-norm or WCC data.
%          The function will fail (cryptically) if not a calibration file.
%
% INPUTS
%      dicomHdr:     Filename of dicom file, or dicom header (read by 
%                    dicominfo either with or without pet-dicom-dict.txt)
%      outDirectory: directory to write CAL extracted from the dicom data
%
% OUTPUTS:
%       outFilename: name of output file (norm2d, geo2d, wcc2d (or 3d))
%
% SYNTAX:
%       outFilename = extractCalibrationFileFromDicom(dicomHdr, outDirectory);
%
% Copyright 2018 General Electric Company.  All rights reserved.
