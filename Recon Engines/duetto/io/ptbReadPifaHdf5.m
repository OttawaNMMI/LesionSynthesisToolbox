% FILE NAME: ptbReadPifaHdf5.m
%
% Reads a pifa from the provided filename location and returns a pifa
% structure
%
% Inputs:
%       pifaFilename: PIFA version 2 file to be read (HDF5 format)
% Output:
%       structure containing PIFA header and pifa floating point data
%
% Optionally, a "dataOnly" flag can be invoked to return only the PIFA data.
%
% Examples:
%   pifaStruct = ptbReadPifaHdf5('Abdomen.1.1.CompPifa.hdf');
%   pifaData   = ptbReadPifaHdf5('Abdomen.1.1.CompPifa.hdf','dataOnly');
