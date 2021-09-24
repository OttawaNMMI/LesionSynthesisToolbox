% GEh5DisplayGroupTree(outFile, inFilePath, groupLoc, omitList, omitListLen)
%
% Recursively display HDF5 group datasets and attribtues from "inFilePath".
%
% Notes:
%   Use GEh5DisplayGroupData() to display group datasets and attributes non-recursively.
%
% Inputs:
%   inFilePath  - HDF5 input file path
%   groupLoc    - either a group struct as returned from h5info() or an absolute group path string
