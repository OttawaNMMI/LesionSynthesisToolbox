function dirName = duettoToolboxLocation
% FILENAME: duettoToolboxLocation
%
% PURPOSE: Return the directory-name where the Duetto is installed
%
% WARNING: The implementation of this function depends on its location;
%          you will have to adjust the implementation if you move it.

% Find filename based on where the current function is based
dirName = fileparts(mfilename('fullpath'));

% You can use the following if duettoToolboxLocation.m is not in the root of the Duetto
% curdir=pwd;
% cd(dirname)
% cd('..');
% dirname=pwd;
% cd(curdir)
% clear curdir

