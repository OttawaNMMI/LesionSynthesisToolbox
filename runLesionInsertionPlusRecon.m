% runLesionInsertionPlusRecon - driver function uses directory w/ lesion
% synthesis parameters (previously generated) to generate projection files
% for the lesion(s). This function takes the previously generated
% lesion files and creates a single lesion map, initilizes simulation 
% parameters and calls the most important functino LesionInsertion_TOFV4. 
%
% Lesion Synthesis at this time is only supported using the GE RECON 
% TOOLOX (VER: REGRECON5) for Time-of-flight reconstructions. For
% development/modifications/access to source code please contact 
% GE Healthcare PET image reconstrcution development team 
% (As of early 2019: Michael.Spohn@ge.com)
%
% This function uses tools from the GE RECON TOOLBOX (REGRECON5) and
% therefore needs REGRECON5 in the available directory
%
% Usage: 
% ======
% runLesionInsertionPlusRecon(fname,patdatadir)
%
% fname - Directory where the lesion parameters are stored and lesion
% synthesis files should be generated 
%
% patdatadir - Typically this folder should have two
% stored directies within. The first is a CTAC folder with the slices of
% the patient CTAC image used to ATTEN CORR by the GE RECON TOOLBOX.
%
% Next Steps: LesionInsertion_GEPETreconParams, LesionInsertion_TOFV4,
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2018
% Last Modified: April 30 2019

function runLesionInsertionPlusRecon(patdatadir,fname,reconName)

%fname = '/home/hanif/Documents/TOFLesionInsertion_MainFSystem/Patient_13187';
%patdatadir = '/media/hanif/HANIFHDD/Console Data/Local Patient DB/13187';

recondir = fname; 

% Load the gold truth image..if only worth gold

if ~exist([patdatadir filesep 'ir3d.sav'])
	noGT = 1; 
else
	imgGT = readSavefile([patdatadir filesep 'ir3d.sav']);
	noGT = 0; 
end

[p f e] = fileparts(patdatadir); 

if isempty(reconName)
	reconName = ['Patient_' num2str(f)];
end

fname = [fname filesep reconName];

% Grab the previously generated lesion synthesis parameters
load([fname filesep 'LesionParams_' reconName '.mat'],'lesion','lesionCount')     


if noGT 
	imgGT = ones(size(lesion{1}.map)); 
end 

% Create a single matrix with all the lesions 
lesionImg = zeros(size(lesion{1}.map)); 
for i = 1:lesionCount-1
    lesionImg = lesionImg + lesion{i}.map; 
end 

% Multiple the lesion binary map (indicies are lesion-to-background factors)
% with the target image to create projections that will be added to the
% target image projections 
lesionImg = lesionImg .* imgGT; 

% Typically used for debugging or when the system crashes mid synthesis 
LIparams.copyFiles = 1; % yes you want to copy the files over 
LIparams.baselineRecon = 1; % Typically want this on 
LIparams.genLesionFiles = 1; % Yes I want to generate the lesion projections
LIparams.mainFS = 1; % only necessary when running on the linux machine..it got werid sometimes 

if lesionCount <=2 
	LIparams.LesionBedPosRecon = 1; 
	disp('RECON ONLY THE BED POS WHERE LESION IS LOCATED')
else 
	LIparams.LesionBedPosRecon = 0; 
end 


%LIparams.LesionBedPosRecon = 1; % Recon ALL bed positions

% Fourth version is the best..casue who even like 1-3? 
LesionInsertion_TOFV4(reconName,lesionImg,patdatadir,LIparams,recondir)

% Anonymize Recon 
dirIn = [recondir filesep reconName filesep 'CTreconWithLesion' filesep,...
	'Synthetic_Lesion_Offline_3D'];

mkdir([recondir filesep reconName],[reconName '_DICOM'])

dirOut = [recondir filesep reconName filesep reconName '_DICOM']; 

hdrOverwrite = struct('PatientName',reconName,...
					'PatientID',reconName,...
					'ReferringPhysicianName','Discovery Toolbox',...
					'StudyDescription','Discovery Toolbox',...
					'SeriesDescription',reconName); 
% In order for anon to work, recon must spit out recon files in DICOM
% format .. 
anonGEreconOutput(dirIn, dirOut, hdrOverwrite)


%% Clean Up
% Projections
for i = 1:20
	projName = [recondir filesep reconName filesep 'CTreconWithLesion',...
		filesep 'LesionProjs_frame' num2str(i)];
	if exist(projName)
		movefile(projName,...
			[recondir filesep reconName]);
		disp('Archived simulated projections') 
		disp(projName)
	end
	
end

reconMatDir = [recondir filesep reconName filesep 'CTreconWithLesion',...
	filesep 'ir3d.sav'];

if exist(reconMatDir)
	movefile(reconMatDir,...
		[recondir filesep reconName]);
	disp('Archived recon sav file')
	disp(reconMatDir)
end

reconDICOMDir = [recondir filesep reconName filesep 'CTreconWithLesion',...
	filesep 'Synthetic_Lesion_Offline_3D'];

if exist(reconDICOMDir)
	movefile(reconDICOMDir,...
		[recondir filesep reconName]);
	disp('Archived recon DICOM files')
	disp(reconDICOMDir)
end

reconParamsDir = [recondir filesep reconName filesep 'CTreconWithLesion',...
	filesep 'Params.mat'];

if exist(reconParamsDir)
	movefile(reconParamsDir,...
		[recondir filesep reconName]);
	disp('Archived recon sav file')
	disp(reconParamsDir)
end

cd([recondir filesep reconName])

rmdir([recondir filesep reconName filesep 'CTreconWithLesion'],'s')
rmdir([recondir filesep reconName filesep 'Baseline_PET'],'s')

%% 
end
