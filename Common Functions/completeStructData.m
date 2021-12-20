% COMPLETESTRUCTDATA - completes the fields in the data structure using 
% the default data.
% data = completeStructData(data,defdata)

% By Ran Klein 8-Jan-2007


% *******************************************************************************************************************
% *                                                                                                                 *
% * Copyright [2014] Ottawa Heart Institute Research Corporation.                                                   *
% * This software is confidential and may not be copied or distributed without the express written consent of the   *
% * Ottawa Heart Institute Research Corporation.                                                                    *
% *                                                                                                                 *
% *******************************************************************************************************************


function data = completeStructData(data,defdata)

if ~isempty(defdata)
	if isempty(data)
		data = defdata;
	else
		fnames = fieldnames(defdata);
		for i = 1:length(fnames)
			if isstruct(defdata.(fnames{i})) % the field is a structure
				if isfield(data,fnames{i})
					data.(fnames{i}) = completeStructData(data.(fnames{i}),defdata.(fnames{i}));
				else
					data.(fnames{i}) = defdata.(fnames{i});
				end
			else
				if ~isfield(data,fnames{i}) || isempty(data.(fnames{i})) ||...
						(ischar(data.(fnames{i})) && (strcmpi(data.(fnames{i}),'Automatically Choose') ||...
						strcmpi(data.(fnames{i}),'Default Option') ||...
						strcmpi(data.(fnames{i}),'Default'))) % use default values
					data.(fnames{i}) = defdata.(fnames{i});
				end
			end % isstruct
		end % field loop
	end % isempty data
end