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



% TO DO - determine if there is suitable baseline data to copy over from
% the lesion archive

function runLesionInsertionPlusRecon_WebApp(lesionParamsFile)

load(lesionParamsFile, 'info')
patDataDir = info.patDataDir;
simulationName = info.reconName;
% baseDir = [info.simulationDir filesep info.patientID ' - ' simulationName]; 
baseDir = fileparts(lesionParamsFile);

if ~isfield(info,'simulationArchiveDir') || isempty(info.simulationArchiveDir)
	disp('No archive directory provided. Leaving results in the simulation directory');
	archiveDataFlag = false;
	archiveDir = '';
else
	archiveDir = info.simulationArchiveDir;
	if ~exist(archiveDir,'dir')
		mkdir(archiveDir)
	end
	disp(['Final results will be archiving to ' archiveDir filesep simulationName '. Intermediate files will be deleted']);
	archiveDataFlag = true;
end



% Typically used for debugging or when the system crashes mid synthesis 
LIparams.copyFiles = 'auto'; % yes you want to copy the files over 
LIparams.baselineRecon = 'auto'; % {'yes','no','auto'}
LIparams.genLesionFiles = 1; % Yes I want to generate the lesion projections
LIparams.LesionBedPosRecon = []; % reconstruct only the bed positions associated with the lesions - otherwise all bed positions.

% Run Lesion Insertion
% status = LesionInsertionTOF_WebApp(simulationName, lesionParamsFile, patDataDir, LIparams, baseDir, archiveDir);
status = LesionInsertionDUETTO_WebApp(simulationName, lesionParamsFile, patDataDir, LIparams, baseDir, archiveDir);

% change directory to avoid error trying to remove this directory
cd(info.simulationDir);

%% Finalize and archive results files 
if archiveDataFlag
	% Fix the DICOM files first
	dirIn = [baseDir filesep 'reconWithLesion' filesep, info.simParams.SeriesDesc];
	dirOut = [archiveDir filesep simulationName filesep info.reconProfile '_DICOM'];
	mkdir(dirOut)
	fixGEReconDICOMOutput(dirIn, dirOut)
	
	% Fix the mat file second as the header comes from the DICOM series
	makefIR3DmatFile([baseDir filesep 'reconWithLesion'], [archiveDir filesep simulationName filesep info.reconProfile '_fIR3D.mat']);

	% Move the lesion parameters file
	movefile(lesionParamsFile, [archiveDir filesep simulationName filesep info.reconProfile '_LesionParams.mat']);
	
	% Send results to DICOM node
	if isfield(info,'DICOMSend')
		sendCmd = ['"' which('storescu.exe') '" -aet ' info.DICOMSend.SourceAET ' -aec ' info.DICOMSend.TargetAET ' -v ' info.DICOMSend.TargetHost ' ' num2str(info.DICOMSend.TargetPort) ' '];
		disp('Sending lesion PET to DICOM:')
		disp(sendCmd)
		[status, response] = system([sendCmd '+sd "' dirOut '"']);
		disp('DICOM send response:')
		disp(response);
		if info.DICOMSend.IncludeCT
			disp('Sending CT data to DICOM:')
			disp(sendCmd)
			[status, response] = system([sendCmd '+sd "' baseDir filesep 'reconWithLesion' filesep 'CTAC"']);
			disp('DICOM send response:')
			disp(response);
		end
	end	
	
	% Clean up temporary directory
	rmdir(baseDir,'s')
	
	%% Test that lesion intenisties are as expected
	% TO DO - fix me
% 	testLesionIntensities([archiveDir filesep simulationName]);
	
else % Don't archive the data - leave at all where it was processed   TO DO: not tested
	
	% Reorganize the data
	% Projections - TO DO: Don't want to keep these
	for i = 1:20
		projName = [baseDir filesep simulationName filesep 'reconWithLesion',...
			filesep 'LesionProjs_frame' num2str(i)];
		if exist(projName,'file')
			movefile(projName,...
				[baseDir filesep simulationName]);
			disp('Archived simulated projections')
			disp(projName)
		end
	end

	% Volumetric image
	reconMatFilename = [baseDir filesep simulationName filesep 'reconWithLesion',...
		filesep 'ir3d.sav'];
	
	if exist(reconMatFilename,'file')
		movefile(reconMatFilename,...
			[baseDir filesep simulationName]);
		disp('Archived recon sav file')
		disp(reconMatFilename)
	end


	% Lesion data DICOM series without fixing data
	reconDICOMDir = [baseDir filesep simulationName filesep 'reconWithLesion',...
		filesep 'Synthetic_Lesion_Offline_3D'];
	
	if exist(reconDICOMDir,'dir')
		movefile(reconDICOMDir,...
			[baseDir filesep simulationName]);
		disp('Archived recon DICOM files')
		disp(reconDICOMDir)
	end

	% instruction for reconstruction of lesion data - redundant with
	% lesionParams file.
	reconParamsFilename = [baseDir filesep simulationName filesep 'reconWithLesion',...
		filesep 'reconParams.mat'];
	
	if exist(reconParamsFilename,'file')
		movefile(reconParamsFilename,...
			[baseDir filesep simulationName]);
		disp('Archived recon sav file')
		disp(reconParamsFilename)
	end
	
end

end
