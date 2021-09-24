function runImageReconServer(command, dataDir, pushbulletTocken)

persistent ReconServerTimer

if nargin<1
	command = 'start';
end
if nargin<2
	p = fileparts(mfilename('fullpath'));
	p = fileparts(p);
	load([p filesep 'DataDirectories'],'ReconQueueDir')
	dataDir = [ReconQueueDir filesep 'reconQ'];
end
if nargin<3
	pushbulletTocken = '';
end

options = struct('dataDir', dataDir,...
			      'pushbulletTocken', pushbulletTocken,...
				  'parallelComputing', false); % TO DO
			  
command = lower(command);
if contains(command,'debug')
	options.parallelComputing = false;
	command = strrep(command,'debug','');
	command = strrep(command,'-','');
	command = strtrim(command);
end	  
			  
switch command
	case 'start'
		if ~isempty(ReconServerTimer) && ishandle(ReconServerTimer) && strcmpi(ReconServerTimer.Running,'on')
			disp('Simulation server is already running')
			return
		end
					
		% TO DO - limit number of job workers to avoid destabilizing the
		% system
		ReconServerTimer = timer('TimerFcn',@ReconServerService,...
			'ExecutionMode','FixedDelay',...'FixedSpacing',...
			'Period',5.0,'BusyMode','Drop','Userdata', options,'Tag','Reconstruction Server');
		start(ReconServerTimer);
	case {'kill','stop'}
		stop(ReconServerTimer);
		delete(ReconServerTimer);
		ReconServerTimer = [];
	case 'one time'
		ReconServerService(options)
end
end

function ReconServerService(hObject, event)
if isstruct(hObject)
	options = hObject;
	startTime = now;
else
	options = hObject.UserData;
	startTime = event.Data.time;
end
dataDir = options.dataDir;
disp([datestr(startTime) ' : Starting Reconstruction Server Service on ' dataDir])
files = listfiles('*_reconParams.mat', dataDir, 's');
nfiles = length(files);
disp([' - ' num2str(nfiles) ' directories to process'])

pushbulletH = Pushbullet(options.pushbulletTocken);

if options.parallelComputing
	
	parObj = parpool(3); % Currently limited by temporary storage primarily
	parfor i = 1:nfiles
		try
			reconParamFile = [dataDir filesep files{i}];
			ReconJob(reconParamFile)
			pushMessage(pushbulletH)
		catch err
			err.getReport
			pushMessage(pushbulletH)
		end
	end
	delete(parObj);
	
else % serial porocessing
	
	for i = 1:nfiles
		try
			reconParamFile = [dataDir filesep files{i}];
			ReconJob(reconParamFile)
			pushMessage(pushbulletH)
		catch err
			err.getReport
			pushMessage(pushbulletH)
		end
	end
	
end

delete(pushbulletH);

end
 

%% Call the recon process corresponding to the ReconToolbox
function ReconJob(reconParamFile)
load(reconParamFile,'info');
switch info.reconParams.ReconToolbox
	case 'DUETTO'
		ReconJob_DUETTO(reconParamFile);
	otherwise
		ReconJob_GEPETRecon(reconParamFile);
end
end

%% DUETTO
function ReconJob_DUETTO(reconParamFile)
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
copyfile([info.patDataDir filesep 'raw'],[patientDir filesep 'raw'])
copyfile([info.patDataDir filesep 'CTAC'],[patientDir filesep 'CTAC'])
copyfile([info.patDataDir filesep 'norm3d'],[patientDir filesep 'norm3d.RDF'])
copyfile([info.patDataDir filesep 'geo3d'],[patientDir filesep 'geo3d.RDF'])

cd(patientDir)

userConfig = ptbUserConfig(info.reconParams.Algorithm);

%reconParams = LesionInsertion_GEPETreconParams; % gen Default LI Params
%reconParams.genCorrectionsFlag = 1; %Turn Corrections on

userConfig.dicomSeriesDesc = info.reconName;
userConfig.dicomImageSeriesDesc = [info.reconParams.SimName '_BaselineRecon'];
userConfig.nX = info.reconParams.nXdim;
% reconParams.ny = info.reconParams.nYdim;
% reconParams.nz = 47; % PER BED POS

userConfig.nSubsets =  info.reconParams.Subsets;
userConfig.nIterations = info.reconParams.Iterations;
userConfig.zFilter = info.reconParams.zfilter;
userConfig.postFilterFwhm = info.reconParams.FilterFWHM;
userConfig.beta = info.reconParams.beta;

userConfig.attenDataDir = [patientDir filesep 'CTAC'];

% TO DO: don't want this hardcoded
userConfig.nParallelThreads = 4;
vol = ptbRunRecon(userConfig);
% To load the volume from the saved DICOM use
% vol = ptbReadAndOrientDicom([patientDir filesep info.reconName]);
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
files = listfiles('*.sdcopen', [patientDir filesep info.reconName]);
infodcm = dicominfo([patientDir filesep info.reconName filesep files{1}]);

% Make one clean mat file of the reconstructed image
[hdr, infodcm] = hdrInitDcm(infodcm);
save([patientDir filesep info.reconName '_fIR3D.mat'], 'vol', 'hdr', 'infodcm');

cd(fileparts(patientDir))

[~, f, ~] = fileparts(patientDir);
if lastPatientRecon(patientDir)
	disp('Moving results to archive directory')
	% clean up
	movefile(patientDir, [info.saveDir filesep f], 'f');
else
	disp('Copying results to archive directory')
	% keep the raw and intermediate files for next recon of data
	copyfile(patientDir, [info.saveDir filesep f] ,'f');
	delete(reconParamFile)
	%TO DO: Need to delete all _reconParams.mat from the saveDir that don't
	%apply.
end

disp('Making a mat file image for the CT in the archive')
makeCTmatFile([info.saveDir filesep f filesep 'CTAC']);
end






%% GEPETRecon - deprecated by DUETTO
function ReconJob_GEPETRecon(reconParamFile)
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
copyfile([info.patDataDir filesep 'CTAC'],[patientDir filesep 'CTAC'])
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

% Make one clean mat file of the reconstructed image
[hdr, infodcm] = hdrInitDcm(infodcm);
save([patientDir filesep info.reconName '_fIR3D.mat'], 'vol', 'hdr', 'infodcm');

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

makeCTmatFile([info.saveDir filesep f filesep 'CTAC']);
end




%% Determine if this is the last reconstruction for this patient
function result = lastPatientRecon(patientDir)
files = listfiles('*_reconParams.mat', patientDir);
result = length(files) == 1;
end