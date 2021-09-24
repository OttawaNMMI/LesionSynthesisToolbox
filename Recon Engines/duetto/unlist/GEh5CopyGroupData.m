% GEh5CopyGroupData(inFilePath, groupLoc, outFilePath)
%
% Copy the HDF5 datasets and attribute data at the given "groupLoc" from "inFilePath" to "outFilePath".
% Subgroups are not processed (i.e. non-recursive).
% 
% Notes:
%   Use GEh5CopyGroupTree() to recursively copy group datasets and attributes for all subgroups.
%
% Inputs:
%   inFilePath  - HDF5 input file path
%   groupLoc    - either a group struct as returned from h5info() or an absolute group path string
%   outFilePath - HDF5 output file path (may or may not already exist)
