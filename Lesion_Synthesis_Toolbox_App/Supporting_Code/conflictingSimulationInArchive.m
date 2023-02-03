% conflictingSimulationInArchive - Tests if there is a conflict between a
% simulation and its intended archive destination.
%
% Usage: conflict = conflictingSimulationInArchive(info, lesion, refROI) -
% where info, lesion and refROI are the structures in a *_lesionParams.mat
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
	files = listfiles('*_lesionParams.mat', dir);
	if ~isempty(files)
		info1 = load([dir filesep files{1}]);
		conflict = ~isequaln(info1.lesion, lesion) || ~isequaln(info1.refROI, refROI);
	end
end
