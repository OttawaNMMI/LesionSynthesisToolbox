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
% stored directies within. The first is a CTAC_DICOM folder with the slices of
% the patient CTAC image used to ATTEN CORR by the GE RECON TOOLBOX.
%
% Next Steps: LesionInsertion_GEPETreconParams, LesionInsertion_TOFV4,
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2018
% Last Modified: April 30 2019



% TO DO - determine if there is suitable baseline data to copy over from
% the lesion archive

function img = runImageRecon_WebApp(reconParamFile)
load(reconParamFile,'info');
switch info.reconParams.ReconToolbox
	case 'DUETTO'
		img = ReconJob_DUETTO(reconParamFile);
	otherwise
		ReconJob_GEPETRecon(reconParamFile);
end
end

%% DUETTO
function img = ReconJob_DUETTO(reconParamFile)
disp('======================================================================================================')
disp('|                                                                                                    |')
disp(['|  Starting DUETTO recon job for: ' reconParamFile repmat(' ',1, 67-length(reconParamFile)) '|'])   
disp('|                                                                                                    |')
disp('======================================================================================================')
disp(' ')

load(reconParamFile,'info');

% TO DO - rethink this, as cannot reconstruct two reconstructions in the
% same directory. 
patientDir = fileparts(reconParamFile);

% Copy the necessary files to Baseline PET dirs
if isMissingRawData(patientDir)
	copyfile([info.patDataDir filesep 'raw'],[patientDir filesep 'raw'])
	copyfile([info.patDataDir filesep 'CTAC_DICOM'],[patientDir filesep 'CTAC_DICOM'])
	copyfile([info.patDataDir filesep 'norm3d'],[patientDir filesep 'norm3d.RDF'])
	copyfile([info.patDataDir filesep 'geo3d'],[patientDir filesep 'geo3d.RDF'])
end

cd(patientDir)

userConfig = ptbUserConfig(info.reconParams.Algorithm);

%reconParams = LesionInsertion_GEPETreconParams; % gen Default LI Params
%reconParams.genCorrectionsFlag = 1; %Turn Corrections on

userConfig.dicomSeriesDesc = info.reconParams.SeriesDesc;
userConfig.dicomImageSeriesDesc = [info.reconParams.SimName '_BaselineRecon'];
userConfig.nX = info.reconParams.nXdim;
% reconParams.ny = info.reconParams.nYdim;
% reconParams.nz = 47; % PER BED POS

userConfig.nSubsets =  info.reconParams.Subsets;
userConfig.nIterations = info.reconParams.Iterations;
userConfig.zFilter = info.reconParams.zfilter;
userConfig.postFilterFwhm = info.reconParams.FilterFWHM;
userConfig.beta = info.reconParams.beta;

userConfig.attenDataDir = [patientDir filesep 'CTAC_DICOM'];

userConfig.nParallelThreads = getLSTThreads;
vol = ptbRunRecon(userConfig);
% vol = ptbReadSaveFile('ir3d.sav'); % to load vol

%% Clean up parallel pool
delete(gcp('nocreate'));
myCluster = parcluster('local');
delete(myCluster.Jobs);

%% Clean up unclosed files
fId = fopen('all');
if ~isempty(fId)
	disp('Someone left files open:');
	for i=1:length(fId)
		disp(fopen(fId(i)));
	end
	fclose('all');
	disp('But we closed them');
end

% This is where the DICOM series is saved
% dicomDir = [patientDir filesep userConfig.dicomSeriesDesc];
dicomDir = [patientDir filesep info.reconName];
movefile([patientDir filesep userConfig.dicomSeriesDesc], dicomDir)

% Fix the DICOM files to include radiopharmaceutical information
fixGEReconDICOMOutput(dicomDir);

disp('Take a breath')
pause(3);

% Make one clean mat file of the reconstructed image
files = listfiles('*.sdcopen', dicomDir);
infodcm = dicominfo([dicomDir filesep files{1}]);
[hdr, infodcm] = hdrInitDcm(infodcm);
save([patientDir filesep info.reconName '_fIR3D.mat'], 'vol', 'hdr', 'infodcm');
img = struct('vol', vol,...
			'hdr', hdr,...
			'infodcm', infodcm);

cd(fileparts(patientDir))

% [~, f, ~] = fileparts(patientDir);
archiveDir = [info.saveDir filesep hdr.patientID];
if ~exist(archiveDir,'dir')
	mkdir(archiveDir)
end

if ~exist([archiveDir filesep 'CTAC.mat'], 'file')
	disp('Making a mat file image for the CT in the archive')
	makeCTmatFile([patientDir filesep 'CTAC_DICOM'], [archiveDir filesep 'CTAC.mat']);
end

if lastPatientRecon(patientDir)
	disp('Moving all results and intermediates to archive directory')
	% clean up
	movefile(patientDir, info.saveDir, 'f');
else
	disp(['Moving results to archive directory:' archiveDir])
	% keep the raw and intermediate files for next recon of data
	movefile(dicomDir, archiveDir ,'f');
	movefile(reconParamFile, archiveDir, 'f');
	movefile([patientDir filesep info.reconName '_fIR3D.mat'], archiveDir ,'f');
end

end






%% GEPETRecon - deprecated by DUETTO
function img = ReconJob_GEPETRecon(reconParamFile)
disp('==============================================================')
disp('|                                                            |')
disp(['|  Starting recon job for: ' reconParamFile repmat(' ',1, 34-length(reconParamFile)) '|'])   
disp('|                                                            |')
disp('==============================================================')
disp(' ')

load(reconParamFile,'info');

% TO DO - rethink this, as cannot reconstruct two reconstructions in the
% same directory. 
patientDir = fileparts(reconParamFile);

% Copy the necessary files to Baseline PET dirs
copyfile([info.patDataDir filesep 'raw'],[patientDir filesep 'raw'])
copyfile([info.patDataDir filesep 'CTAC_DICOM'],[patientDir filesep 'CTAC_DICOM'])
copyfile([info.patDataDir filesep 'norm3d'],patientDir)
copyfile([info.patDataDir filesep 'geo3d'],patientDir)

cd(patientDir)

reconParams = LesionInsertion_GEPETreconParams; % gen Default LI Params
reconParams.genCorrectionsFlag = 1; %Turn Corrections on

reconParams.dicomImageSeriesDesc = [info.reconParams.SimName '_BaselineRecon'];
reconParams.nx = info.reconParams.nXdim;
reconParams.ny = info.reconParams.nYdim;

reconParams.nz = 47; % PER BED POS

reconParams.algorithm = info.reconParams.Algorithm;
reconParams.numSubsets =  info.reconParams.Subsets;
reconParams.numIterations = info.reconParams.Iterations;
reconParams.zfilter = info.reconParams.zfilter;
reconParams.postFilterFWHM = info.reconParams.FilterFWHM;
reconParams.beta = info.reconParams.beta;

% This information neverget used again and file names were conflicting
% save([patientDir filesep info.reconName '_ReconParams2.mat'],'reconParams')

% Perform a PET recon with Attenuation Correction [GT: Patient without Lesion]

[vol, infodcm] = GEPETrecon(reconParams);

%% Clean up unclosed files
% TO DO - discuss with GE regarding leaving files open.
fId = fopen('all');
if ~isempty(fId)
	disp('Someone left files open:');
	for i=1:length(fId)
		disp(fopen(fId(i)));
	end
	fclose('all');
	disp('But we closed them');
end

% Fix the DICOM files to include radiopharmaceutical information
fixGEReconDICOMOutput(reconParams.dicomImageSeriesDesc)

% Make one clean mat file of the reconstructed image
[hdr, infodcm] = hdrInitDcm(infodcm);
save([patientDir filesep info.reconName '_fIR3D.mat'], 'vol', 'hdr', 'infodcm');
img = struct('vol', vol,...
			'hdr', hdr,...
			'infodcm', infodcm);

cd(fileparts(patientDir))

[~, f, ~] = fileparts(patientDir);
if lastPatientRecon(patientDir)
	% clean up
	movefile(patientDir, [info.saveDir filesep f], 'f');
else
	% keep the raw and intermediate files for next recon of data
	copyfile(patientDir, [info.saveDir filesep f] ,'f');
	delete(reconParamFile)
	%TO DO: Need to delete all _reconParams.mat fromt he saveDir that don't
	%apply.
end

makeCTmatFile([info.saveDir filesep f filesep 'CTAC_DICOM'], [info.saveDir filesep f filesep 'CTAC.mat']);
end




%% Determine if this is the last reconstruction for this patient
function result = lastPatientRecon(patientDir)
files = listfiles('*_reconParams.mat', patientDir);
result = length(files) == 1;
end

%% Are raw data missing?
function result = isMissingRawData(patientDir)
result = ~(exist([patientDir filesep 'raw'],'dir') && ...
	       exist([patientDir filesep 'CTAC_DICOM'],'dir') && ...
		   exist([patientDir filesep 'norm3d.RDF'],'file') &&...
		   exist([patientDir filesep 'geo3d.RDF'],'file'));
end