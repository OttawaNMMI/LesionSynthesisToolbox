% FILENAME: ptbReadFile
%
% PURPOSE: This function serves as an intermediary for file reading. With
% only minimal changes to the inputs, it can be called for a wide array of
% file types. This function is expandable to other file formats.
%
% INPUTS:
%   filename : Output filename. (extension will be added if needed)
%   fileType : OPTIONAL. If empty, the fileType will be derived from the
%              extension in "filename"
%              Currently supported options:
%                 'sav'  - savefile format
%                 'mat'  - MAT-file format
%                 Any MAT-file-specific format (such as 'v7') will default
%                 to a simple Matlab "load" command, as the version is not
%                 necessary as an argument in "load"
%
% OUTPUTS:
%   data     : newly loaded variable
%
% EXAMPLES:
%   data = ptbReadFile('tempFile.mat');
%   data = ptbReadFile('tempFile.mat', 'mat');
%   data = ptbReadFile('tempFile.mat', 'v6');
%   data = ptbReadFile('tempFile', 'mat');
%   data = ptbReadFile('tempFile.sav');
%   data = ptbReadFile('tempFile.sav', 'sav');
%   data = ptbReadFile('tempFile', 'sav');
%
% Copyright 2018 General Electric Company. All rights reserved.
