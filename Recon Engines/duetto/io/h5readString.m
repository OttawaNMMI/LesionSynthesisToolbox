% h5readString - Read a string data field from an HDF5 file.
%
% This function is an alternative to the build-in Matlab h5read function for
% strings. For a reason that is not fully understood, Matlab's built-in h5read
% sometimes returns a cell array of length 1 for a string field. And, it
% often includes strange characters at the end. For example, this occurs
% intermittently with the RDF field:
%     /HeaderData/ExamData/scanIdDicom
% It has also been observed with HDF5-based PIFA files.
%
% This function calls the alternate hdf5read function. Matlab says that this
% function will disappear at some point, but it works better for now.
% (If "hdf5read" is removed at some point, then the "else" portion of the code
% will be run.)
%
% Inputs:
%      fileName
%      dataSetName
%
% Output:
%      HDF5 field contents
