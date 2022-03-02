% % LSTProcessingService - manages a service to reconstruct images and
% synthesisze lesions. Previously generated parameter files are 
% sequentially processed for the search directory:
% 1) Image reconstruction
% 2) Lesion sysnthesis
%
% Notes: Lesion Synthesis and reconstruction at this time is only supported
% using the GE DUETTO. For
% development/modifications/access to source code please contact 
% GE Healthcare PET image reconstrcution development team 
% (As of early 2019: Michael.Spohn@ge.com)

%
% USAGE
% =====
% LSTProcessingService(command, dataDirs)
%
% Input parameters
% command - 'start' - start the server as a background service
%            'stop'  - stop the server
%            'kill'  - stop the server
%            'one time'  - run the service once
%
%

% Example
% LSTProcessingService('start',{'F:\LST Temp\Simulation Queue','F:\LST Temp\Recon Queue'})
% LSTProcessingService('stop')
% LSTProcessingService('one time debug',{'F:\LST Temp\Simulation Queue','F:\LST Temp\Recon Queue'})

function status = LSTProcessingService(command, dataDirs)

persistent LSTProcessingServiceTimer

if nargin<1
	command = 'start';
end
if nargin<2
	dataDirs = [];
end

options = struct('dataDirs', [],...
				 'parallelComputing', false); % We used to have parallel computing option enabled before we swtiched to DUETTO which is multithreaded.

command = lower(command);
if contains(command,'debug')
	options.parallelComputing = false;
	command = strrep(command,'debug','');
	command = strrep(command,'-','');
	command = strtrim(command);
end

switch lower(command)
	case 'start'
		options.dataDirs = resolveDataDirs(dataDirs);
		if ~isempty(LSTProcessingServiceTimer) && ishandle(LSTProcessingServiceTimer) && strcmpi(LSTProcessingServiceTimer.Running,'on')
			disp('Simulation server is already running')
			return
		end
		timerTag = 'LST Processing Service';
		
		% Avoid multiple services
		LSTProcessingServiceTimer = timerfind('Tag', timerTag);
		if ~isempty(LSTProcessingServiceTimer)
			stop(LSTProcessingServiceTimer)
			delete(LSTProcessingServiceTimer);
		end
		
		LSTProcessingServiceTimer = timer('TimerFcn',@LSTProcessingRoutine,...
			'ExecutionMode','FixedDelay',...'FixedSpacing',...
			'Period',5.0,'BusyMode','Drop','Userdata', options,...
			'Name','LST Processing Service Timer',...
			'Tag',timerTag);
		start(LSTProcessingServiceTimer);
		status = 'running';
	case {'kill','stop'}
		if ~isempty(LSTProcessingServiceTimer)
			stop(LSTProcessingServiceTimer);
			delete(LSTProcessingServiceTimer);
		end
		LSTProcessingServiceTimer = [];
		status = 'stopped';
	case 'one time'
		options.dataDirs = resolveDataDirs(dataDirs);
		LSTProcessingRoutine(options)
		status = 'stopped';
	case 'status'
		if isempty(LSTProcessingServiceTimer)
			status = 'stopped';
		elseif strcmpi(LSTProcessingServiceTimer.Running,'on')
			status = 'running';
		else
			status = 'stopped';
			LSTProcessingServiceTimer.disp
		end
end
end


function dataDirs = resolveDataDirs(dataDirs)
if isempty(dataDirs)
	p = fileparts(mfilename('fullpath'));
	p = fileparts(p);
	try
		load([p filesep 'DataDirectories.mat'], 'simulationQueueDir')
		dataDirs = simulationQueueDir;
	catch
		error('No processing directories specified or DataDirectories.mat configureation file found')
	end
end
end


function LSTProcessingRoutine(hObject, event)
if isstruct(hObject) % this indicates that we launched be calling with "one time" mode
	options = hObject;
	startTime = now;
else % this indicates that we laucnhed as a timer event
	options = hObject.UserData;
	startTime = event.Data.time;
end
dataDirs = options.dataDirs;
disp([datestr(startTime) ' : Starting LST Processing Service on: ' ])
disp(dataDirs)
filenames = listLSTProcessingParamFiles(dataDirs);
nfiles = length(filenames);

if options.parallelComputing
	
	parObj = parpool(2); % Currently limited by temporary storage primarily
	parfor i = 1:nfiles
		runFile(filenames{i})
	end
	delete(parObj);
	
else % Serial porocessing
	
	for i = 1:nfiles
		runFile(filenames{i})
	end
	
end

end


%% List all the parameter files for reconstructions and lesion synthesis
function filenames = listLSTProcessingParamFiles(dataDirs)
reconFilenames = {};
for i=1:length(dataDirs)
	folders = listfolders(dataDirs{i});
	nfolders = length(folders);
	for j=1:nfolders
		subdir = [dataDirs{i} filesep folders{j}];
		reconFilenames = [reconFilenames;...
			strcat(subdir, filesep, listfiles('*_reconParams.mat', subdir))];
	end
end
disp(['Found ' num2str(length(reconFilenames)) ' reconstructions to process'])

simFilenames = {};
for i=1:length(dataDirs)
	folders = listfolders(dataDirs{i});
	nfolders = length(folders);
	for j=1:nfolders
		subdir = [dataDirs{i} filesep folders{j}];
		simFilenames = [simFilenames;...
			strcat(subdir, filesep, listfiles('*_lesionParams.mat', subdir))];
	end
end
disp(['Found ' num2str(length(simFilenames)) ' simulations to process'])

filenames = [reconFilenames; simFilenames];
end

%% run the processing for a parameter file.
function runFile(filename)
try
	if isLesionSynthesisParamFile(filename)
		runLesionInsertionPlusRecon_WebApp(filename);
	else
		runImageRecon_WebApp(filename);
	end
catch err
	err.getReport
end
end

%% Returns true is a lesion synthesis file or false if not (ie. reconstruction file)
function val = isLesionSynthesisParamFile(filename)
val = endsWith(filename, '_LesionParams.mat');
end