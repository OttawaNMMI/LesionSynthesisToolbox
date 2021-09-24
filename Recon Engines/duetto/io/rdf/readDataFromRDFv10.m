%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILENAME: readDataFromRDFv10.m
%
% PURPOSE:  This function reads RDFv10 PET raw data and converts them 
%                  to the current Duetto format (RDFv9). 
%                  The function would be called by readRDF10.m.
%
% INPUT -
%       fname : RDFv10 filename
%       curHDF5loc: Original RDFv9 dataset name
%
% OUTPUT -
%       curDataStruct: data struct read from the RDFv10 file
% 
%     e.g.
%          curDataStruct = readDataFromRDFv10(fname, curHDF5loc);
%
% 
% Copyright 2019 General Electric Company. All rights reserved.
