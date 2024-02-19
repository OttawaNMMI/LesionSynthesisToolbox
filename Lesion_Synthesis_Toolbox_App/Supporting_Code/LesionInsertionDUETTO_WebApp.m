% LesionInsertionDUETTO_WebApp - This function genrates the lesion projection
% files and reconstructs the target image with the synthesic lesions
% inserted.
%
% To generate the projection files, a reconstruction
% of the target patient data is needed to (revert) take the inverse of any
% corrections applied on the lesion projection data. The preliminary recon
% must be generated using indentical recon parameters as the target image
% and therefore a single lesion synthesis is only applicable for the
% reconsruction parameters it was generated with. Once the preliminary
% recon is complete (Baseline_PET), a secondary directory is generated
% and necessary files are copied over.
%
% The second recon is initialized where during the
% reconstruction take individal projections of the lesion(s) are combined
% with projections of the target patient data. The image with synthetic
% lesions are stored in the secondary directory (CTreconWithLesion)
%
% To modify the recon parametrs used: ptbUserConfig
%
% Lesion Synthesis at this time is only supported using the GE RECON
% TOOLOX (VER: DUETTO v2.18) for Time-of-flight reconstructions. For
% development/modifications/access to source code please contact
% GE Healthcare PET image reconstrcution development team
% (As of early 2019: Michael.Spohn@gehealthcare.com)
%
% This function uses tools from the GE RECON TOOLBOX (DUETTO) and
% therefore needs DUETTO in the available directory
%
% Usage:
% ======
% LesionInsertionDUETTO_WebApp(reconName,lesionImg,patdatadir,LIparams)
%
% reconName = 'LesionInsertionExampleEmptyScan_TOF_Test';
%
% lesionImg - matrix describing image with indicies in units of Bq/cc
%
% patdatadir - Typically this folder should have two
% stored directies within. The first is a CTAC_DICOM folder with the slices of
% the patient CTAC image used to ATTEN CORR by the GE RECON TOOLBOX.
%
% LIparams - generated in previous caller function but a cell describing
% the following parameters:
%         LIparams.copyFiles = 1; yes, unless its already present in the
%         necessary directories (used to debugging or crash situations)
%
%         LIparams.baselineRecon = 1; ye , dont need if data was generated in
%         final lesion + patient recon parameters
%
%         LIparams.genLesionFiles = 1; yes gen lesion projections
%
%         LIparams.mainFS = 1; Only for Linux Box Needs to run on the disk
%         with the OS and not other HD?? (most likely a formating error)
%
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2018
% Last Modified: April 30 2019

function status = LesionInsertionDUETTO_WebApp(simulationName, lesionParamsFile, patDataDir, LIparams, baseDir, archiveDir)

disp('WELCOME!!!!')
disp('LesionInsertionDUETTO_WebApp - version that works 2021-07-04')

if nargin<6
	archiveDir = '';
end

% Everything you need to know about lesion and reconstruction paraeters is
% in this file created by the WebApp in function %TO DO -complete
lesionData = load(lesionParamsFile);

if ~isfield(LIparams,'LesionBedPosRecon') || isempty(LIparams.LesionBedPosRecon)
	LIparams.LesionBedPosRecon = strcmpi(lesionData.info.simParams.bedRange,'Bed range with lesions');
end

% Set the important dirs for this simulation
if isempty(simulationName)
	simulationName = ['LesionInsertion - ' datestr(now)];
end

% Create Dir for BASELINE PET TOF Recon
baselinePETdir = [baseDir filesep 'Baseline_PET'];
switch LIparams.copyFiles
	case {'yes',1}
		status.copyFiles = true;
	case {'no',0}
		status.copyFiles = false;
	case {'auto',[]}
		status.copyFiles = false;
		if ~exist(baselinePETdir,'dir')
			mkdir(baselinePETdir)
			status.copyFiles = true;
		end
		if ~exist([baselinePETdir filesep 'raw'],'dir')
			mkdir([baselinePETdir filesep 'raw']);
			status.copyFiles = true;
		end
		if ~exist([baselinePETdir filesep 'CTAC_DICOM'],'dir')
			mkdir([baselinePETdir filesep 'CTAC_DICOM']);
			status.copyFiles = true;
		end
		if ~status.copyFiles
			disp('Automatically determined that RAW PET & CT files already exist in baseline reconstruction directory')
		end
	otherwise
		error(['Unrecognized copyFiles parameter in LIparams ' LIparams.copyFiles])
end

% Determine range of bed positions that apply to the lesions to be
% simulated
lesionData1 = lesionData;
for i=1:length(lesionData1.refROI) % pretend that refROIs are lesions so they get included in reconstruction if necessary. TO DO - revisit should depend on baselineRecon flag
	lesionData1.refROI{i}.mode = 'Bq/cc';
	lesionData1.refROI{i}.PTval = 10000;
end
lesionData1.lesion = [lesionData1.lesion, lesionData1.refROI];
blankImgData.hdr = lesionData1.lesion{1}.hdr;
blankImgData.vol = ones(blankImgData.hdr.xdim, blankImgData.hdr.ydim, blankImgData.hdr.nplanes);
lesionMap = makeLesionImage(blankImgData,lesionData1); % TO DO: Make the Lesion Margin a software parameter
lesionMap = lesionMap.vol>0;

% for i = 1:length(lesionData.refROI)
% 	lesionMap = lesionMap + lesionData.refROI{i}.map;
% end

if LIparams.LesionBedPosRecon
    [bedRange, numBeds, slicePerBed, sliceOverlap] = getBedRangeData(lesionMap, 53, 13);
end

% Copy the necessary files to Baseline PET dirs
if status.copyFiles
	disp('Copying RAW PET & CT files for baseline reconstruction')
	if 1 % copy the entire directory with the corrections files if they exist - can we save time by no regenerating them?
		copyfile(patDataDir, baselinePETdir)
	else
		copyfile([patDataDir filesep 'raw'], [baselinePETdir filesep 'raw'])
		copyfile([patDataDir filesep 'CTAC_DICOM'], [baselinePETdir filesep 'CTAC_DICOM'])
		% TO DO: do we need this????
		copyfile([patDataDir filesep 'norm3d'], [baselinePETdir filesep 'norm3d.RDF'])
		copyfile([patDataDir filesep 'geo3d'], [baselinePETdir filesep 'geo3d.RDF'])
	end
	
	if LIparams.LesionBedPosRecon % TO DO - partial bed simulation/reconstruction not tested
		disp(['Keeping only bed poistions: ' num2str(bedRange)])
		
		files = listfiles('*.*',[baselinePETdir filesep 'raw']);
		index = numBeds - bedRange + 1; % Reverse order cuz thats how RPDC files are stored..
		for j = 1:length(files)
			if contains(files{j},'SINO')
				fileindex = str2double(files{j}(5:end));
				if any(index == fileindex+1)
					disp(['Keeping ' files{j}])
				else
					delete([baselinePETdir filesep 'raw' filesep files{j}])
				end
			elseif contains(files{j},'RPDC')
				[~, ~, ext] = fileparts(files{j});
				fileindex = str2double(ext(2:end));
				if any(index == fileindex) || fileindex == numBeds+1
					disp(['Keeping ' files{j}])
				else
					delete([baselinePETdir filesep 'raw' filesep files{j}])
				end
			else
				disp(['Deleting unexpected file ' files{j}]);
				delete([baselinePETdir filesep 'raw' filesep files{j}])
			end
		end
		
		disp('only recon lesion bed positions')
	end

else
	disp('Not copying RAW PET & CT files')
end

disp('---------------------------------------------------------------------')
disp(['Processing baseline image for ' simulationName])
% Change workspace to Baseline PET recon dir
cd(baselinePETdir)

switch LIparams.baselineRecon
	case {'yes',1}
		status.baselineRecon = true;
	case {'no',0}
		status.baselineRecon = false;
	case {'auto',[]}
		status.baselineRecon = ~isSameReconParam(lesionData.info.simParams, [patDataDir filesep lesionData.info.reconProfile '_ReconParams.mat']);
		baselineImgData = [];
		if ~status.baselineRecon 
			try
				if ~exist([patDataDir filesep lesionData.info.reconProfile '_fIR3D.mat'],'file')
					makefIR3DmatFile(patDataDir,[patDataDir filesep lesionData.info.reconProfile '_fIR3D.mat']);
				end
				disp(['Using baseline image ' patDataDir filesep lesionData.info.reconProfile '_fIR3D.mat']);
				baselineImgData = load([patDataDir filesep lesionData.info.reconProfile '_fIR3D.mat']);
			catch
				status.baselineRecon = true;
			end
		end
		% okay, maybe it exists in the simulation library from a previous run
		if status.baselineRecon && isempty(baselineImgData)
			status.baselineRecon = ~isSameReconParam(lesionData.info.simParams, [baselinePETdir filesep 'ReconParams.mat']);
			if ~status.baselineRecon
				try
					if ~exist([baselinePETdir filesep lesionData.info.reconProfile '_fIR3D.mat'],'file')
						info = struct('reconParams',lesionData.info.simParams,...
							'saveDir', fileparts(patDataDir),...
							'reconName', lesionData.info.reconProfile,...
							'patDataDir', [patDataDir filesep 'raw']);
						info.reconParams.SimName = lesionData.info.reconProfile;
						save([baselinePETdir filesep lesionData.info.reconProfile '_ReconParams.mat'],'info')
						makefIR3DmatFile([baselinePETdir filesep lesionData.info.reconProfile '_ReconParams.mat'], [baselinePETdir filesep lesionData.info.reconProfile '_fIR3D.mat']);
					end
					disp(['Using baseline image ' baselinePETdir filesep lesionData.info.reconProfile '_fIR3D.mat']);
					baselineImgData = load([baselinePETdir filesep lesionData.info.reconProfile '_fIR3D.mat']);
				catch
					status.baselineRecon = true;
				end
			end
		end
	otherwise
		error(['Unrecognized baselineRecon parameter in LIparams ' LIparams.baselineRecon])
end

%% Define and save the recon parameters
% The same recon params as used for a baseline recon and for lesion
% synthesis so that intensities are sampled appropriately (e.g. PVE).
reconParams = ptbUserConfig(lesionData.info.simParams.Algorithm);
reconParams.nX = lesionData.info.simParams.nXdim; 
reconParams.nSubsets =  lesionData.info.simParams.Subsets;
reconParams.nIterations = lesionData.info.simParams.Iterations;
reconParams.zFilter = lesionData.info.simParams.zfilter;
reconParams.postFilterFwhm = lesionData.info.simParams.FilterFWHM;
reconParams.beta = lesionData.info.simParams.beta;
reconParams.attenDataDir = [baselinePETdir filesep 'CTAC_DICOM'];
reconParams.nParallelThreads = getLSTThreads;

if isfield(reconParams, 'reconLevelList')
    tofFlag = reconParams.reconLevelList(end).tofFlag;
else
    tofFlag = reconParams.tofFlag;
end


%% Perrfom a baseline reconstruction
% In the context of LesionSynthesis Toolbox, this is treakier than it at
% first seems, because needs to simulate first reconstructing the baseline
% including archiving in the right location. Best practice is to call 
% runImageRecon_WebApp(filename), where filename contains all the
% reconstruction parameters.

% TO DO - baseline image needs to be trimmed to bedRange
if status.baselineRecon
	disp(['Reconstructing a new baseline image in ' baselinePETdir])
	if 1
		filename = [baselinePETdir filesep lesionData.info.reconProfile '_ReconParams.mat'];
		info = struct('reconParams',lesionData.info.simParams,...
			'saveDir', fileparts(patDataDir),...
			'reconName', lesionData.info.reconProfile,...
			'patDataDir', patDataDir);
		save(filename, 'info')
		baselineImgData =  runImageRecon_WebApp(filename);
		clear('info')
	else
		% Define and save the recon parameters
		info = struct('reconParams',lesionData.info.simParams,...
			'saveDir', fileparts(patDataDir),...
			'reconName', lesionData.info.reconProfile,...
			'patDataDir', [patDataDir filesep 'raw']);
		info.reconParams.SimName = lesionData.info.reconProfile;
		info.reconParams.SeriesDesc = 'LST Baseline Reconstruction';
		save([baselinePETdir filesep lesionData.info.reconProfile '_ReconParams.mat'],'info')

		reconParams.dicomSeriesDesc = lesionData.info.reconProfile;
		reconParams.dicomImageSeriesDesc = [lesionData.info.reconProfile '_BaselineRecon'];

		% Perform a PET recon with Attenuation Correction [GT: Patient without Lesion]
		vol = ptbRunRecon(reconParams);
		%% Clean up parallel pool
		delete(gcp('nocreate'));
		myCluster = parcluster('local');
		delete(myCluster.Jobs);
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

		% This is where the DICOM series is saved
		dir = [baselinePETdir filesep info.reconName];
		files = listfiles('*.sdcopen', dir);
		infodcm = dicominfo([dir filesep files{1}]);


		% Make one clean mat file of the reconstructed image
		hdr = hdrInitDcm(infodcm);
		save([baselinePETdir filesep lesionData.info.reconProfile '_fIR3D.mat'], 'vol', 'hdr', 'infodcm');
		baselineImgData = struct('vol', vol,...
			'hdr', hdr,...
			'infodcm', infodcm);
		if ~isempty(archiveDir)
			disp(['Archiving baseline image data to ' archiveDir filesep 'Baseline_PET']);
			copyfile(baselinePETdir, [archiveDir filesep 'Baseline_PET']); % what about adding the reconProfileName to the image filenames?
		end
	end
end

%% Lesion insertion: create (Poisson-noisy) lesion sinogram in /LesionProjs_frame1
disp('---------------------------------------------------------------------')
disp(['Processing lesion image for ' simulationName])
if LIparams.genLesionFiles
	% The same recon params as used in recon. i.e. These are the default
	% parameters.
	
	reconParams.dicomSeriesDesc = lesionData.info.simParams.SimName;
	reconParams.dicomImageSeriesDesc = [lesionData.info.simParams.SimName '_SimulatedLesions']; 

	lesionImgData = makeLesionImage(baselineImgData, lesionData);
	if LIparams.LesionBedPosRecon
		startSlice = (slicePerBed-sliceOverlap)*(min(bedRange)-1)+1;
		endSlice = startSlice + slicePerBed + (max(bedRange) - min(bedRange)) * (slicePerBed-sliceOverlap);
		lesionImgData.vol = lesionImgData.vol(:,:,startSlice:endSlice);
		lesionImgData.hdr.nplanes = size(lesionImgData.vol,3);
	end 
	
	% Generate Poisson-noisy lesion sinogram in /LesionProjs_frame1
    if tofFlag
	    lesionInsertionDuettoTOF(reconParams, lesionImgData.vol);
    else
        lesionInsertionDuettoNonTOF(reconParams, lesionImgData.vol)
    end
else
	disp('  - nothing to process!!!! Why is this running then?')
end
status.genLesionFiles = LIparams.genLesionFiles;

reconWithLesionDir = [baseDir filesep 'reconWithLesion']; % working directory for recon
if 1
	copyfile(baselinePETdir,reconWithLesionDir)
	cd(reconWithLesionDir);
	
	% Link the TOF Lesion Sinogram Data
    if tofFlag
	    fileFormat = '.mat';
    else
    	fileFormat = '.sav';
    end
    suffix = ['.lesion' fileFormat];
	files = listfiles(['*' suffix], reconWithLesionDir);
	for fi = 1:length(files)
		prefix = files{fi}(1:end-length(suffix));
		disp(['Lesions inserted into ' prefix])
		movefile([reconWithLesionDir filesep prefix fileFormat], [reconWithLesionDir filesep prefix '.noLesion' fileFormat]);
		movefile([reconWithLesionDir filesep prefix suffix], [reconWithLesionDir filesep prefix fileFormat]);
	end
else
	mkdir(reconWithLesionDir);
	cd(reconWithLesionDir);
	
	copyfile([baselinePETdir filesep 'raw'],[reconWithLesionDir filesep 'raw'])
	copyfile([baselinePETdir filesep 'CTAC_DICOM'],[reconWithLesionDir filesep 'CTAC_DICOM'])
	copyfile([baselinePETdir filesep 'norm3d.RDF'],reconWithLesionDir)
	copyfile([baselinePETdir filesep 'geo3d.RDF'],reconWithLesionDir)
	
	% Link the TOF Lesion Sinogram Data
	
	for fi = 1:numBeds
		prefix = ['tofPrompts_f' num2str(fi) 'b1'];
		if exist([baselinePETdir filesep prefix '.lesion.mat'], 'file')
			disp(['Lesions inserted into ' prefix])
			copyfile([baselinePETdir filesep prefix '.lesion.mat'], [reconWithLesionDir filesep prefix '.mat']);
		else
			copyfile([baselinePETdir filesep prefix '.mat'], reconWithLesionDir);
		end
	end
end

%% Recon with registered CT AC using inserted lesion data
disp('---------------------------------------------------------------------')
disp(['Reconstructing images with lesions for ' simulationName])

% Reuse the same recon parameters as baseline, but updated.
reconParams.dicomSeriesDesc = lesionData.info.simParams.SeriesDesc;
reconParams.dicomImageSeriesDesc = lesionData.info.simParams.SeriesDesc; %'Synthetic_Lesion_Offline_3D';
reconParams.workDir = reconWithLesionDir;
reconParams.petDataDir = [reconWithLesionDir filesep 'raw'];
reconParams.attenDataDir = [reconWithLesionDir filesep 'CTAC_DICOM'];
reconParams.extractDataFlag = 0; % New 3/7/2021

disp('Lesion:')
disp(reconParams)

reconParams.nParallelThreads = getLSTThreads;
% Save the recon parameters for future reference
save reconParams ;

% Perform PET reconstruction
ptbRunRecon(reconParams);

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
status.lesionSynthesis = true;

%% Insert the lesion in the CT as well - QUINN
if synthesizeInCT(lesionData)
	uid = dicomuid; % give each CT a unique UID
	CTmatFile = [baselinePETdir filesep 'CTAC.mat'];
	if ~exist(CTmatFile,'file')
		CTmatFile = [reconWithLesionDir filesep 'CTAC.mat'];
		makeCTmatFile([reconWithLesionDir filesep 'CTAC_DICOM'], CTmatFile)
	end
	baselineCTImgData = load(CTmatFile);
	lesionCTImgData = simulateCTLesion(baselineCTImgData, lesionData);
	lesionCTImgData.dicominfo.SeriesInstanceUID = uid;
	
	save([reconWithLesionDir filesep 'CTAC.mat'], '-struct', 'lesionCTImgData')

	%Update the DICOM
	files = listfiles('*.*',[reconWithLesionDir filesep 'CTAC_DICOM']);
	nfiles = (length(files));
	assert(nfiles==size(baselineCTImgData.vol,3))
	parfor i=1:nfiles
		info = dicominfo([reconWithLesionDir filesep 'CTAC_DICOM' filesep files{i}]);
		if strcmpi(info.PatientPosition,'FFS')
			img = lesionCTImgData.vol(:,:,nfiles-info.InstanceNumber+1)';  % fix image orientation
		else
			img = lesionCTImgData.vol(:,:,info.InstanceNumber)';  % fix image orientation
		end
        img = img - info.RescaleIntercept; % account for rescaleIntercept in header
		info.SeriesInstanceUID = uid; % avoid multiple CTs interacting on PACS
% 		info.StudyInstanceUID = studyUid; % associate with corresponding PET
		if ~startsWith(info.SeriesDescription, 'NON_DIAGNOSTIC')
			info.SeriesDescription = ['NON_DIAGNOSTIC_' info.SeriesDescription];
		end
		dicomwrite(img, [reconWithLesionDir filesep 'CTAC_DICOM' filesep files{i}], info, 'CreateMode', 'copy');
	end
	status.CTlesionSynthesis = true;
else
	status.CTlesionSynthesis = false;
end

%% Clean up parallel pool
delete(gcp('nocreate'));
myCluster = parcluster('local');
delete(myCluster.Jobs);

end

%% Are the reconstruction parameters the same? Detemrine need for baseline reconstruction to be performed.
function isSame = isSameReconParam(reconParamsSim, reconParamsBL)
if ischar(reconParamsSim)
	reconParamsSim = load(reconParamsSim);
	reconParamsSim = reconParamsSim.info.simParams;
end
if ischar(reconParamsBL)
	if exist(reconParamsBL,'file')
		disp(['Reading baseline image reconstruction parameters from: ' reconParamsBL])
		reconParamsBL = load(reconParamsBL);
		if isfield(reconParamsBL,'info') % this is a reconstruction record crated by us
			reconParamsBL = reconParamsBL.info.reconParams;
		elseif isfield(reconParamsBL,'reconParams') % this is a GE reconstrcution parameter file
			reconParamsBL = reconParamsBL.reconParams;
		else % we don't know what this file is
			disp(' - abort, we don''t know what file type this is');
			isSame = false;
			return
		end
	else
		isSame = false;
		return
	end
end
if isfield(reconParamsBL,'mracExtDir') % GE parameters
	isSame = ...
		reconParamsBL.nX == reconParamsSim.nXdim && ...		reconParamsBL.nZdim == reconParamsSim.nZdim && ...
		contains(reconParamsSim.Algorithm, reconParamsBL.reconLevelList(end).reconAlgorithm.char) && ...
		contains(reconParamsSim.Algorithm, 'TOF') == reconParamsBL.reconLevelList(end).tofFlag && ...
		((contains(reconParamsSim.Algorithm,'OSEM') && reconParamsBL.nSubsets ==  reconParamsSim.Subsets  && ...
		reconParamsBL.nIterations == reconParamsSim.Iterations)  || ...
		(~contains(reconParamsSim.Algorithm,'OSEM') && reconParamsBL.beta == reconParamsSim.beta)) && ...
		reconParamsBL.postFilterFwhm == reconParamsSim.FilterFWHM  && ...
		reconParamsBL.zFilter == reconParamsSim.zfilter;
else
	isSame = ...
		reconParamsBL.nXdim == reconParamsSim.nXdim && ...
		reconParamsBL.nZdim == reconParamsSim.nZdim && ...
		strcmp(reconParamsBL.Algorithm, reconParamsSim.Algorithm)  && ...
		((contains(reconParamsSim.Algorithm,'OSEM') && reconParamsBL.Subsets ==  reconParamsSim.Subsets  && ...
		reconParamsBL.Iterations == reconParamsSim.Iterations)  || ...
		(~contains(reconParamsSim.Algorithm,'OSEM') && reconParamsBL.beta == reconParamsSim.beta)) && ...
		reconParamsBL.FilterFWHM == reconParamsSim.FilterFWHM  && ...
		reconParamsBL.zfilter == reconParamsSim.zfilter;
end
end

%% Do we also need to synthesize a lesion in the CT?
function res = synthesizeInCT(lesionData)
res = false;
for i=1:length(lesionData.lesion)
	if ~isnan(lesionData.lesion{i}.CTval)
		res = true;
	end
end
end
