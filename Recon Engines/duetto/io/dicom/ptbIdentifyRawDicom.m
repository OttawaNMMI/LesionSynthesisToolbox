% FILENAME: ptbIdentifyRawDicom
%
% PURPOSE:  For each filename matching the pattern, this function will print
%           what type of file it is plus some basic information.
%
% INPUTS:
%       filenamePattern: Pattern for matlab's dir function. The pattern can have directory information.
%       generalParams:  (for verbosity flag)
%
% OUTPUT:
%       RPDCInfo: array of structs (one per SeriesInstanceUID) with basic info
%           The structure contains the fields:
%               StudyID, SeriesInstanceUID, SeriesNumber, SeriesDescription,
%               scan_datetime (as a Dicom DT string),
%               PatientID, PatientPosition, binning_mode, frameOffset,
%               numBedPositions, numTimeFrames, numGates, RawFiles,
%               CalibrationFiles
%
%  The last 2 fields are structure arrays with information per file (including fname).
%  The elements in the RawFiles array are sorted first by frameStartTime
%  (millisecs since scan_starttime), then acq_bin_num (if present), then start_location.
%  Note that numTimeFrames==numBedPositions for multi-bed position data (e.g "regular"
%  whole-body acquisition).
%  frameOffset set only if bed positions change in regular steps. Otherwise a warning is issued.
%
% Copyright (c) 2019 General Electric Company. All rights reserved.
