% listfiles - lists files matching a pattern in a directory.
%
% USAGE:
% ======
% files=listfiles(strpat, directory, flag)
%
% files=listfiles(strpat) - list all the file with strpat
% pattern in the current directory.returns files ia a cell 
% structure of the file names that meet the pattern in the direcotry.
% strpat can be a string or cell of strings with the file patterns to
% match. Examples: '*.dcm',  {'*.001','*.002','*.003'}, or 'comp*'. '*' indicates
% wild card, and is optional at the start of strpat.
%
% files=listfiles(strpat, directory) - Searches for matching files in 
% directory (may or may not have a '\' at the end).
%
% files=listfiles(strpat, directory, flag) - additional search flags:
%     s - recursively search in the subdirectories.
%     d - include directories in the results. Otherwise, only files are returned.
%
% EXAMPLES:
% =========
% 1) All files with extentions .m in the current directory
% listfiles('*.m', pwd)
% ans =
% 
%   4×1 cell array
% 
%     {'compileC.m'             }
%     {'duettoToolboxLocation.m'}
%     {'getDuettoVersion.m'     }
%     {'initializeDuetto.m'     }
%
% By Ran Klein 22/2/2005

% 23-Feb-05 JR - added 'all' strpat and changed strpat to type cell
% 18-Jul-08 RK - changed all '\' to filesep to support other OS
%              - added flag for search options. s - recursive directory
%                search.


% *******************************************************************************************************************
% *                                                                                                                 *
% * Copyright [2014] Ottawa Heart Institute Research Corporation.                                                   *
% * This software is confidential and may not be copied or distributed without the express written consent of the   *
% * Ottawa Heart Institute Research Corporation.                                                                    *
% *                                                                                                                 *
% *******************************************************************************************************************


function files=listfiles(strpat, directory, flag)

if strcmp(strpat,'all')
    strpat = {'.v','.i','.v6','.w','.GEimg','.img','.raw','_processed.mat','_reten.mat','CT.mat','_dicomDST','dicomGXL','DICOMDIR.','.simset'};
elseif ~iscell(strpat)
    strpat = {strpat};
end

files={};
if nargin<1
	error('No search pattern passed to listfiles');
end

if nargin<2 || isempty(directory)
    directory = pwd;
end
if directory(end) == filesep
	directory = directory(1:end-1);
end

if nargin<3
	flag = '';
end

dir_struct = [];
for j=1:length(strpat)
	dir_struct=[dir_struct; dir([directory filesep strrep(['*' strpat{j}],'**','*')])];
end

% % Added by Ran Klein 2011-03-01
% if any(lower(flag)=='d')
%     dir_struct = [dir_struct;  dir([directory filesep '*'])];
% end
% Keep only files - or directory if flagged
% commented out 2023-03-29 - this didn't make sense as it ended up listing
% all directories, even the onese that didn't match the search string.

sorted_names = unique(sortrows({dir_struct.name}'));
for i=1:length(sorted_names)
	if ~all(sorted_names{i}=='.') &&...
			(exist([directory filesep sorted_names{i}],'file') || ... is a file
			(any(lower(flag)=='d') && exist([directory filesep sorted_names{i}],'dir')))
		files = [files; sorted_names{i}];
	end
end

% recursive diretory search
if any(lower(flag)=='s')
	subdirs = dir([directory filesep '*.']);
	for i=1:length(subdirs)
		if subdirs(i).isdir
			subdir = subdirs(i).name;
			if subdir(1)~='.' % ignore . and .. dirs
				sublist = listfiles(strpat, [directory filesep subdir], flag);
				if ~isempty(sublist)
					files = [files; strcat([subdir filesep], sublist)];
				end
			end
		end
	end
end
