% Like matlab's 'dir' function but preserves path info
% When Matlab's 'dir' function gets called with a path, it returns
% a structure array with filenames that do not have the path
% information. This can be inconvenient. This function does not
% have this behaviour, i.e. it prepends the path info to the filenames.
% Aside from this, in its simplest form, it acts like 'dir', but more complicated
% usage patterns are possible.
%
% USAGE:
%   files=findFiles('somepath/*DC*');
%   =>Returns a structure array with filenames (including directories) that start with 'somepath/'.
%   files=findFiles('somepath');
%   =>Returns a structure array with all filenames in the 'somepath'
%     directory that start with 'somepath/'.
%   files=findFiles({pattern1, pattern2,...});
%   =>Returns a structure array with all filenames that match any of the patterns
%   files=findFiles(structure_array);
%   => As a convenience for other functions, returns the array itself.
% OPTIONS
%   'depth': default: 1
%      if depth>1, include all files in subdirectories up to 'depth' levels down
%  EXAMPLE
%   files=findFiles('somepath/gate*', 'depth',2)
%   => Returns all files and directories matching 'somepath/gate*', and all files
%      that are in subdirectories whose name matches 'somepath/gate*/'
% PLATFORM DEPENDENCY
% This function uses Matlab's dir, fileparts and fullpath, so will
% have the same platform dependencies.
% LIMITATION
% Sadly, complicated patterns such as 'gate*/*.dcm' or 'gate?' do not work.
%
