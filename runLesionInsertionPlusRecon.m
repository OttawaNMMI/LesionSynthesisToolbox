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

function runLesionInsertionPlusRecon(patdatadir,fname)

%fname = '/home/hanif/Documents/TOFLesionInsertion_MainFSystem/Patient_13187';
%patdatadir = '/media/hanif/HANIFHDD/Console Data/Local Patient DB/13187';

recondir = fname; 

% Load the gold truth image..if only worth gold
imgGT = readSavefile([patdatadir filesep 'ir3d.sav']);

[~, f, ~] = fileparts(patdatadir); 

reconName = ['Patient_' num2str(f)]; 

fname = [fname filesep reconName];

% Grab the previously generated lesion synthesis parameters
load([fname filesep 'LesionParams_' reconName '.mat'],'lesion','lesionCount')     

% Create a single matrix with all the lesions 
lesionImg = zeros(size(lesion{1}.map)); 
for i = 1:lesionCount-1
    lesionImg = lesionImg + lesion{i}.map; 
	disp('FIX ME HERE')
	%%
	% We want to first sample the target patient data, and then take an average
	% of the sample, and then multiple by the scaling factor
end 

% Multiple the lesion binary map (indicies are lesion-to-background factors)
% with the target image to create projections that will be added to the
% target image projections 
lesionImg = lesionImg .* imgGT; 

% Typically used for debugging or when the system crashes mid synthesis 
LIparams.copyFiles = 1; % yes you want to copy the files over 
LIparams.baselineRecon = 0; % Only if you really want to gen a baseline recon but multiple time to sim by 2 
LIparams.genLesionFiles = 1; % Yes I want to generate the lesion projections
LIparams.mainFS = 1; % only necessary when running on the linux machine..it got werid sometimes 

% Fourth version is the best..casue who even like 1-3? 
LesionInsertion_TOFV4(reconName,lesionImg,patdatadir,LIparams,recondir)

% Anonymize Recon 
dirIn = [recondir filesep reconName filesep 'CTreconWithLesion' filesep,...
	'Synthetic_Lesion_Offline_3D'];

mkdir([recondir filesep reconName],[reconName '_DICOM'])

dirOut = [recondir filesep reconName filesep reconName '_DICOM']; 

hdrOverwrite = struct('PatientName','ANON0001',...
					'PatientID','0000001',...
					'ReferringPhysicianName','DELETE',...
					'StudyDescription','Synthetic Lesions - Test Toolbox',...
					'SeriesDescription','Testing Toolbox'); 

anonGEreconOutput(dirIn, dirOut, hdrOverwrite)
end