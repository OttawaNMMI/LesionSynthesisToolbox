% GEh5DisplayGroupData(outFile, inFilePath, groupLoc, omitList, omitListLen)
%
% Display the HDF5 datasets and attribute data at the given "groupLoc" from "inFilePath".
% Subgroups are not processed (i.e. non-recursive).
% 
% Notes:
%   Use GEh5DisplayGroupTree() to recursively display group datasets and attributes for all subgroups.
%
% Inputs:
%   inFilePath  - HDF5 input file path
%   groupLoc    - either a group struct as returned from h5info() or an absolute group path string
