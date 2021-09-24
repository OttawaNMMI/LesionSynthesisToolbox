% GEh5CopyGroupTree(inFilePath, groupLoc, outFilePath)
%
% Recursively copy HDF5 group datasets and attribtues from "inFilePath" to "outFilePath".
%
% Notes:
%   Use GEh5CopyGroupData() to copy group datasets and attributes non-recursively.
%
% Inputs:
%   inFilePath  - HDF5 input file path
%   groupLoc    - either a group struct as returned from h5info() or an absolute group path string
%   outFilePath - HDF5 output file path (may or may not already exist)
