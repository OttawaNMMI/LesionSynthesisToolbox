% GEh5GetGroupInfo(inFilePath, groupLoc)
%
% Given a HDF5 file path and group location, return a group struct as returned from h5info().
%
% Inputs:
%   inFilePath - HDF5 input file
%   groupLoc   - either already a group struct as returned from h5info() or an absolute group path string
% 
% Outputs:
%   group      - always a group struct as returned from h5info()
