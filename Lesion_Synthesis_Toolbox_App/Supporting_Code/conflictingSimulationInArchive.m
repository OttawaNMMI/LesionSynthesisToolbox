% conflictingSimulationInArchive - Tests if there is a conflict between a
% simulation and its intended archive destination.
%
% Usage: conflict = conflictingSimulationInArchive(info, lesion, refROI) -
% where info, lesion and refROI are the structures in a *_LesionParams.mat
% file.
%
% First tests the archive directory already exists. Then looks for
% lesionParam.mat files in it. Using the first such file it checks whether
% the same lesion and refROI parameters are used; in which cases that is
% fine. If the parameters defer, that is a conflict.
%
% See also: LesionSynthesisToolbox

% By Ran Klein, The Ottawa Hospital, 2023-02-03

function conflict = conflictingSimulationInArchive(info, lesion, refROI)

conflict = false;
dir = [info.simulationArchiveDir filesep info.reconName];
if exist(dir,'dir')
	files = listfiles('*_LesionParams.mat', dir);
	if ~isempty(files)
		info1 = load([dir filesep files{1}]);
		% enough to ensure that these belong the the same original scan if
		% the StudyInstanceUID are the same. ALso check that same number of
		% lesions and refROI, so that for loops below are simpler.
		conflict = ~strcmp(lesion{1}.hdr.StudyInstanceUID, info1.lesion{1}.hdr.StudyInstanceUID) || ...
			length(info1.lesion) ~= length(lesion) || length(info1.refROI) ~= length(refROI);
		if ~conflict
			% ignore the header, as a simulation and original
			% reconstruction header will not be identical.
			for i=1:length(lesion)
				info1.lesion{i} = rmfield(info1.lesion{i}, 'hdr');
				lesion{i} = rmfield(lesion{i}, 'hdr');
			end
			for i=1:length(refROI)
				info1.refROI{i} = rmfield(info1.refROI{i}, 'hdr');
				refROI{i} = rmfield(refROI{i}, 'hdr');
			end
			conflict = ~isequaln(info1.lesion, lesion) || ~isequaln(info1.refROI, refROI);
		end
	end
end
