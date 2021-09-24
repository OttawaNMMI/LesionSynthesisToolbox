%--------------------------------------------------------------------------
%
%							THE OTTAWA HOSPITAL
%						Division of Nuclear Medicine
%
%--------------------------------------------------------------------------
%
% batchExtractLesionSlices m-file
%
% Driver function to call extractSimulatedLesionSlice and batch process all
% the reconstructed simulations within a single directory. Single
% transaxial (TA) slices are saved as ".mat" files using the reconName
% naming convention used when defining the simulation parameters
%
% Usage:		batchExtractLesionSlices(reconDir,saveDir)
%
%				reconDir - [string] directory where simulated
%						   reconstructions are archived
%				saveDir  - [string] directory where the single TA slices
%						   will be saved
% Output [0]: N/A
%
%
% Developer		: HJUMA (hjuma@toh.ca)
% Date Created	: Aug 1 2019
% Last Edited	: Aug 9 2019
% Edit Notes    : Updated help section & warning/error messages - HJUMA Aug7
%               : Support to extract SUV image as well - HUMA Aug 9
% Also See		: extractSimulatedLesionSlice
%
% Notes			:

function batchExtractLesionSlices(reconDir,saveDir)

if nargin < 1
	warning('No input directory to search')
	return
end

[p f e] = fileparts(reconDir);

if nargin < 2
	disp(['Saving extracted TA slices at: ' p filesep f '_SingleTAslices'])
	saveDir = [f '_SingleTAslices'];
	mkdir(p,saveDir)
	saveDir = [p, saveDir]; % filesep already included
end

temp = dir(reconDir);
count = 1;

for i = 1:length(temp)
	if strfind(temp(i).name,'.')
		
	else
		flders{count} = temp(i).name;
		count = count +1;
	end
end

for i = 1:length(flders)
	searchDir = [reconDir filesep flders{i}];
	fReconImg = [searchDir filesep 'ir3d.sav'];
	fReconImg = [searchDir filesep 'fIR3D.mat'];
	if ~contains(fReconImg,'Broken')
		if exist(fReconImg)
			[eImg, lmap, cROI] = extractSimulatedLesionSlice(fReconImg);
			[p,~,~] = fileparts(fReconImg);
			[~,f,~] = fileparts(p);
			load([p filesep 'IR3D_SUV.mat'])
			img = img(:,:,cROI(3));
			save([saveDir filesep f '.mat'],'eImg','lmap','img');
			
		else
			warning(['Could not locate reconImg at: ' searchDir])
			continue % move on to next iteration
		end
	else 
		disp(['Skipped: ' fReconImg])
	end 
	
end

end