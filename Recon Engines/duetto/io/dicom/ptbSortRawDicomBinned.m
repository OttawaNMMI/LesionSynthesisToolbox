% FILENAME: ptbSortRawDicomBinned
%
% PURPOSE: Extract RDFs and Calibration files from RPDC DICOM files
%
% INPUTS:
%       rpdcInfo: array of structures as returned by ptbIdentifyRawDicom
%       outDir: directory name where to put sinograms, norm and wcc RDF files
%       Optional pairs:
%           fieldname, value pairs for down-selection of series
%           any field in rpdcInfo can be used. Equality will be tested using "isequal".
%
% OUTPUTS:
%       outSinoFilenames: cell-array containing all filenames of the RDFs
%           with sinogram data with pattern: f1b1.rdf, ... f[i]b[j].rdf. 
%       outCalFilenames: cell-array containing all filenames of the RDFs
%           with calibration data files on disk: norm.rdf, 
%
% SYNTAX:
%   rpdcInfo = ptbIdentifyRawDicom('raw/*RPDC*');
%   [rdfFiles, calFiles] = ptbSortRawDicom(rpdcInfo, '.');
%
% This function should handle dynamic/gated data or gated/multi-bed data.
% Note that dynamic gated data should be written with the gate index running fastest.
%
% It replaces the "sortRawDicom" function in the pettoolbox which only handles multi-bed data.
%
% TODO: currently dynamic/gated/multi-bed data will not work because
%       it is unclear how to sort and call files
%
% Copyright 2018 General Electric Company.  All rights reserved.
