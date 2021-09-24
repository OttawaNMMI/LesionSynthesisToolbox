% FILENAME: ptbWriteFile
%
% PURPOSE: This function serves as an intermediary for file writing. With
% only minimal changes to the inputs, it can be called for a wide array of
% file types. This function is expandable to other file formats. 
% Note that this function does not support the saving of multiple variables.
%
% INPUTS:
%   data     : variable to be saved
%              (can be any format supported by underlying file format)
%   filename : output filename (extension will be added if needed)
%   fileType : OPTIONAL; if empty, the fileType will be derived from the
%              extension in "filename"
%              Currently supported options:
%                 'sav'  - savefile format
%                 'mat'  - MAT-file format
%                 'v7.3' - MAT-file version 7.3 format
%                 'v7'   - MAT-file version 7 format
%                 'v6'   - MAT-file version 6 format
%                 'v*'   - MAT-file version * format
%              If a MAT-file version other than the default is desired,
%              "fileType" must be set to the desired version.
%
% EXAMPLES:
%    ptbWriteFile(data, 'tempFile.mat');
%    ptbWriteFile(data, 'tempFile', 'mat');
%    ptbWriteFile(data, 'tempFile.mat', 'V7.3');
%    ptbWriteFile(data, 'tempFile', 'V7.3');
%    ptbWriteFile(data, 'tempFile.sav');
%    ptbWriteFile(data, 'tempFile', 'sav');
%
% Copyright 2018 General Electric Company. All rights reserved.
