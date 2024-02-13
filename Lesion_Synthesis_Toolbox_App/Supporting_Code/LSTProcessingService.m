% % LSTProcessingService - manages a service to reconstruct images and
% synthesisze lesions. Previously generated parameter files are 
% sequentially processed for the search directory:
% 1) Image reconstruction
% 2) Lesion synthesis
%
% Notes: Lesion Synthesis and reconstruction at this time is only supported
% using the GE DUETTO. For
% development/modifications/access to source code please contact 
% GE Healthcare PET image reconstrcution development team 
% (As of early 2019: Michael.Spohn@gehealthcare.com and/or Elizabeth.Philps@med.gehealthcare.com)
%
%
% USAGE
% =====
% LSTProcessingService(command, dataDirs)
%
% Input parameters
% command -  'start' - start the server as a background service
%            'stop'  - stop the server
%            'kill'  - stop the server
%            'one time'  - run the service once
%
% Examples:
% LSTProcessingService('start',{'F:\LST Temp\Simulation Queue','F:\LST Temp\Recon Queue'})
% LSTProcessingService('stop')
% LSTProcessingService('one time debug',{'F:\LST Temp\Simulation Queue','F:\LST Temp\Recon Queue'})
%
% See also: runImageRecon_WebApp, runLesionInsertionPlusRecon_Webapp

% By Ran Klein, The Ottawa Hospital, 2022

function status = LSTProcessingService(command, dataDirs)

if nargin<1
	command = 'start';
end
if nargin<2
	dataDirs = [];
end

timerTag = 'LST Processing Service'; % tag of the timer for the processing service trigger
statusFile = [tempdir filesep 'LSTServiceStatus.txt']; % File indicating status of the LST service
refreshTime = 3/24/60/60; % seconds interval to determine if service is running

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
		if strcmpi(LSTProcessingService('status'),'Running')
			disp('LST Service is already running. A new service cannot be started. Stop the process first and then restart.')
			if usejava('desktop')
				return;
			else
				exit;
			end
		else
			options.dataDirs = resolveDataDirs(dataDirs);

			LSTProcessingServiceTimer = timer('TimerFcn',@LSTProcessingRoutine,...
				'ExecutionMode','FixedDelay',...
				'StartDelay',2,...
				'Period',5.0,'BusyMode','Drop','Userdata', options,...
				'Name','LST Processing Service Timer',...
				'Tag',timerTag);
			start(LSTProcessingServiceTimer);

			startStatusRefresh(statusFile, LSTProcessingServiceTimer);
		end
		status = 'running';
	case {'kill','stop'}
		LSTProcessingServiceTimer = timerfind('tag',timerTag);
		if ~isempty(LSTProcessingServiceTimer)
			stop(LSTProcessingServiceTimer);
			delete(LSTProcessingServiceTimer);
		end
		
		stopStatusRefresh;

		status = 'stopped';
	case 'one time'
		options.dataDirs = resolveDataDirs(dataDirs);
		
		startStatusRefresh(statusFile, 'One time');
		
		LSTProcessingRoutine(options)
		
		stopStatusRefresh;

		status = 'stopped';
	case 'status'
		if 0 % old way of doing it, but will not work for as a service running ina differnt MatLab environment
			if isempty(LSTProcessingServiceTimer)
				status = 'stopped';
			elseif strcmpi(LSTProcessingServiceTimer.Running,'on')
				status = 'running';
			else
				status = 'stopped';
				LSTProcessingServiceTimer.disp
			end
		else
			if exist(statusFile,'file')
				try
					fID = fopen(statusFile,"r");
					lastUpdated = fgetl(fID);
					fclose(fID);
					timeDiff = now()-datenum(lastUpdated);
					if timeDiff<0 || timeDiff>refreshTime
						status = 'stopped';
					else
						status = 'running';
					end
				catch
					status = 'stopped';
				end
			else
				status = 'stopped';
			end
		end
end
end


function LSTProcessingServiceStatusTimer = startStatusRefresh(statusFile, LSTProcessingServiceTimer)
% this service will update the status file with a time stamp
% every second. The status can be monitored using the following
% to test if the service is running:
%       strcmpi(LSTProcessingService('status'),'Running')
LSTProcessingServiceStatusTimer = timer('TimerFcn',@refreshStatus,...
	'ExecutionMode','FixedDelay',...
	'Period',1.0,'BusyMode','Drop',...
	'Name','LST Processing Service Status Timer',...
	'Tag','LST Processing Service Status Timer',...
	'UserData',struct('statusFile',statusFile,...
	                  'timerHandle',LSTProcessingServiceTimer));
start(LSTProcessingServiceStatusTimer);
disp('Started status referesh timer')
end


function LSTProcessingServiceStatusTimer = stopStatusRefresh
LSTProcessingServiceStatusTimer = timerfind('tag','LST Processing Service Status Timer');
data = get(LSTProcessingServiceStatusTimer, 'UserData');
if ~isempty(LSTProcessingServiceStatusTimer)
	stop(LSTProcessingServiceStatusTimer);
	delete(LSTProcessingServiceStatusTimer);
end
LSTProcessingServiceStatusTimer = [];
if isfield(data,'statusFile') && exist(data.statusFile,'file')
	delete(data.statusFile)
end
end


function refreshStatus(hObject, event)
data = get(hObject,'UserData');
% LSTProcessingServiceTimer = timerfind('Tag', data.timerTag);
if ischar(data.timerHandle) && strcmpi(data.timerHandle,'One time') || ~isempty(data.timerHandle) && strcmpi(data.timerHandle.Running,'on')
	fID = fopen(data.statusFile,"w+");
	fprintf(fID, datestr(now(),31));
	fclose(fID);
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
		error('No processing directories specified or DataDirectories.mat configuration file found.')
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