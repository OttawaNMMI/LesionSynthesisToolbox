% LesionInsertion_TOFV4 - This function genrated the lesion projection
% files and reconstructs the target image with the synthesic lesions
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
% To modify the recon parametrs used: LesionInsertion_GEPETreconParams
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
% LesionInsertion_TOFV4(reconName,lesionImg,patdatadir,LIparams)
%
% reconName = 'LesionInsertionExampleEmptyScan_TOF_Test';
%
% lesionImg - matrix describing image with indicies in units of Bq/cc
%
% patdatadir - Typically this folder should have two
% stored directies within. The first is a CTAC folder with the slices of
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
% Next Step: LesionInsertion_TOFV4
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2018
% Last Modified: April 30 2019

function status = LesionInsertionTOF_WebApp(simulationName, lesionParamsFile, patDataDir, LIparams, baseDir, archiveDir)

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

% Create Dir for all simulation related files
mkdir(baseDir)

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
		if ~exist([baselinePETdir filesep 'CTAC'],'dir')
			mkdir([baselinePETdir filesep 'CTAC']);
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
lesionMap = makeLesionImage(blankImgData,lesionData1);
lesionMap = lesionMap.vol>0;

% for i = 1:length(lesionData.refROI)
% 	lesionMap = lesionMap + lesionData.refROI{i}.map;
% end
[bedRange, numBeds, slicePerBed, sliceOverlap] = getBedRangeData(lesionMap);

% Copy the necessary files to Baseline PET dirs
if status.copyFiles
	disp('Copying RAW PET & CT files for baseline reconstruction')
	if 1 % copy the entire directory with the corrections files if they exist - can we save time by no regenerating them?
		copyfile(patDataDir, baselinePETdir)
	else
		copyfile([patDataDir filesep 'raw'], [baselinePETdir filesep 'raw'])
		copyfile([patDataDir filesep 'CTAC'], [baselinePETdir filesep 'CTAC'])
		copyfile([patDataDir filesep 'norm3d'], baselinePETdir)
		copyfile([patDataDir filesep 'geo3d'], baselinePETdir)
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
		status.baselineRecon = ~isSameReconParam(lesionData.info.simParams, [patDataDir filesep 'ReconParams.mat']);
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
						makefIR3DmatFile(baselinePETdir,[baselinePETdir filesep lesionData.info.reconProfile '_fIR3D.mat']);
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

% The same recon params as used in recon. i.e. These are the default
% parameters.
reconParams = LesionInsertion_GEPETreconParams;
reconParams.nx = lesionData.info.simParams.nXdim; 
reconParams.ny = lesionData.info.simParams.nYdim; 
reconParams.nz = slicePerBed;
reconParams.algorithm = lesionData.info.simParams.Algorithm;
reconParams.numSubsets =  lesionData.info.simParams.Subsets;
reconParams.numIterations = lesionData.info.simParams.Iterations;
reconParams.zfilter = lesionData.info.simParams.zfilter;
reconParams.postFilterFWHM = lesionData.info.simParams.FilterFWHM;
reconParams.beta = lesionData.info.simParams.beta;

% TO DO - turn off results for each iteration
% TO DO - baseline image needs to be trimmed to bedRange
if status.baselineRecon 
	disp(['Reconstructing a new baseline image in ' baselinePETdir])
	% Define and save the recon parameters
	reconParams.genCorrectionsFlag = 1; %Turn Corrections on if need be - TO DO: baselineReconCorrectionFilesPresent
	reconParams.dicomImageSeriesDesc = [lesionData.info.reconProfile '_BaselineRecon'];
	save([baselinePETdir filesep 'ReconParams.mat'],'reconParams')
	
	% Perform a PET recon with Attenuation Correction [GT: Patient without Lesion]
	[vol, infodcm] = GEPETrecon(reconParams);
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

disp('---------------------------------------------------------------------')
disp(['Processing lesion image for ' simulationName])

% Lesion insertion: create (Poisson-noisy) lesion sinogram in /LesionProjs_frame1
if LIparams.genLesionFiles
	% The same recon params as used in recon. i.e. These are the default
	% parameters.
% 	reconParams.nx = 512; % TO DO: if this is just the image for simulating lesion (not reconstructing), can we use a finer samping matrix?
% 	reconParams.ny = 512;
    reconParams.genCorrectionsFlag = 0; % TO DO: is this required if the baseline has been performed? Presumably we are not generating correction during simulation
	reconParams.dicomImageSeriesDesc = [lesionData.info.simParams.SimName '_SimulatedLesions']; 
	% Lesion insertion flag
	reconParams.lesionInsertionTOFFlag = 1;
	
	lesionImgData = makeLesionImage(baselineImgData, lesionData);
	if LIparams.LesionBedPosRecon
		startSlice = (slicePerBed-sliceOverlap)*(min(bedRange)-1)+1;
		endSlice = startSlice + slicePerBed + (max(bedRange) - min(bedRange)) * (slicePerBed-sliceOverlap);
		lesionImgData.vol = lesionImgData.vol(:,:,startSlice:endSlice);
		lesionImgData.hdr.nplanes = size(lesionImgData.vol,3);
	end 
	
	% Generate Poisson-noisy lesion sinogram in /LesionProjs_frame1
	lesionInsertion(lesionImgData.vol,reconParams);
end
status.genLesionFiles = LIparams.genLesionFiles;

% Recon with registered CT AC using inserted lesion data
CTreconWithLesionDir = [baseDir filesep 'CTreconWithLesion']; % working directory for recon
mkdir(CTreconWithLesionDir);
cd(CTreconWithLesionDir);

% Need to copy these files and not move them
% TO DO - why not copy all the correction files as well to save time?????
copyfile([baselinePETdir filesep 'raw'],[CTreconWithLesionDir filesep 'raw'])
copyfile([baselinePETdir filesep 'CTAC'],[CTreconWithLesionDir filesep 'CTAC'])
copyfile([baselinePETdir filesep 'norm3d'],CTreconWithLesionDir)
copyfile([baselinePETdir filesep 'geo3d'],CTreconWithLesionDir)
% Link the TOF Lesion Sinogram Data
for i = 1:numBeds
	
	LesProjName = ['LesionProjs_frame' num2str(i)];
	
	if exist([baselinePETdir filesep LesProjName],'dir')
		mkdir(CTreconWithLesionDir,LesProjName)
		movefile([baselinePETdir filesep LesProjName],CTreconWithLesionDir) % was copyfile - but trying to save precious disk space
% 		copyfile([baselinePETdir filesep LesProjName],[CTreconWithLesionDir filesep LesProjName]) 
		disp(['Linked ' LesProjName])
	else % Delete other files
		% 		f = listfiles(['.' num2str(i)],[CTreconWithLesionDir filesep 'raw']);
		% 		for L = 1:size(f,1)
		% 			n = f{L};
		% 			if contains(n,'SINO')
		% 				sinoname = [n(1:end) num2str(i-1)];
		% 			elseif contains(n,'RPDC')
		% 				rawname = n;
		% 			end
		% 		end
		% 		if ~exist('sinoname')
		% 			sinoname = ['SINO000' num2str(i-1)];
		% 		end
		% 		sinoname = [CTreconWithLesionDir filesep 'raw' filesep sinoname];
		% 		rawname  = [CTreconWithLesionDir filesep 'raw' filesep rawname ];
		%
		% 		delete(sinoname)
		% 		delete(rawname)
	end
	% 	clear sinoname
	% 	clear rawname
end

reconParams = LesionInsertion_GEPETreconParams;
reconParams.dicomImageSeriesDesc = lesionData.info.simParams.SeriesDesc; %'Synthetic_Lesion_Offline_3D';
reconParams.nx = lesionData.info.simParams.nXdim; 
reconParams.ny = lesionData.info.simParams.nYdim; 
reconParams.nz = slicePerBed;
reconParams.algorithm = lesionData.info.simParams.Algorithm;
reconParams.numSubsets =  lesionData.info.simParams.Subsets;
reconParams.numIterations = lesionData.info.simParams.Iterations;
reconParams.zfilter = lesionData.info.simParams.zfilter;
reconParams.postFilterFWHM = lesionData.info.simParams.FilterFWHM;
reconParams.beta = lesionData.info.simParams.beta;
reconParams.lesionInsertionTOFFlag = 1; % Lesion insertion flag
reconParams.genCorrectionsFlag = 1; % TO DO - is this the right thing to do?

% Save the recon parameters for future reference
save reconParams ;

% Perform PET reconstruction
GEPETrecon(reconParams);
status.lesionSynthesis = true;

end


function isSame = isSameReconParam(reconParamsSim, reconParamsBL)
if ischar(reconParamsSim)
	reconParamsSim = load(reconParamsSim);
	reconParamsSim = reconParamsSim.info.simParams;
end
if ischar(reconParamsBL)
	if exist(reconParamsBL,'file')
		reconParamsBL = load(reconParamsBL);
		reconParamsBL = reconParamsBL.reconParams;
	else
		isSame = false;
		return
	end
end
isSame = ...
    reconParamsBL.nx == reconParamsSim.nXdim && ...
    reconParamsBL.ny == reconParamsSim.nYdim && ...
	reconParamsBL.nz == reconParamsSim.nZdim && ...
	strcmp(reconParamsBL.algorithm, reconParamsSim.Algorithm)  && ...
    ((contains(reconParamsSim.Algorithm,'OSEM') && reconParamsBL.numSubsets ==  reconParamsSim.Subsets  && ...
    reconParamsBL.numIterations == reconParamsSim.Iterations)  || ...
	(~contains(reconParamsSim.Algorithm,'OSEM') && reconParamsBL.beta == reconParamsSim.beta)) && ...
	reconParamsBL.postFilterFWHM == reconParamsSim.FilterFWHM  && ...
	reconParamsBL.zfilter == reconParamsSim.zfilter;
end