% runSimulationServer - starts the lesion simulation service on a specified
% directory in which lesion parameters are stored for each directory.
%
% USAGE
% =====
% runSimulationServer(command, dataDir)
%
% Input parameters
% command - 'start' - start the server as a background service
%            'stop'  - stop the server
%            'kill'  - stop the server
%            'one time'  - run the service once
%
%

function runSimulationServer(command, dataDir, pushbulletTocken)

persistent SimServerTimer

if nargin<1
	command = 'start';
end
if nargin<2
	p = fileparts(mfilename('fullpath'));
	p = fileparts(p);
	load([p filesep 'DataDirectories'], 'simulationQueueDir')
	dataDir = simulationQueueDir;
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
		if ~isempty(SimServerTimer) && ishandle(SimServerTimer) && strcmpi(SimServerTimer.Running,'on')
			disp('Simulation server is already running')
			return
		end
					
		% TO DO - limit number of job workers to avoid destabilizing the
		% system
		SimServerTimer = timer('TimerFcn',@SimulationServerService,...
			'ExecutionMode','FixedDelay',...'FixedSpacing',...
			'Period',5.0,'BusyMode','Drop','Userdata', options,'Tag','Lesion Sythesis Simulation Server');
		start(SimServerTimer);
	case {'kill','stop'}
		stop(SimServerTimer);
		delete(SimServerTimer);
		SimServerTimer = [];
	case 'one time'
		SimulationServerService(options)
end
end



function SimulationServerService(hObject, event)
if isstruct(hObject)
	options = hObject;
	startTime = now;
else
	options = hObject.UserData;
	startTime = event.Data.time;
end
dataDir = options.dataDir;
disp([datestr(startTime) ' : Starting Simulation Server Service on ' dataDir])
folders = listfolders(dataDir);
nfolders = length(folders);
disp([' - ' num2str(nfolders) ' lesion studies to process'])

pushbulletH = Pushbullet(options.pushbulletTocken);

if options.parallelComputing
	
	parObj = parpool(2); % Currently limited by temporary storage primarily
	parfor i = 1:nfolders
		try
			lesionParamsFile = [dataDir filesep folders{i}];
			files = listfiles('*_LesionParams.mat',lesionParamsFile);
			lesionParamsFile = [lesionParamsFile filesep files{1}];
			runLesionInsertionPlusRecon_WebApp(lesionParamsFile)
			pushMessage(pushbulletH)
		catch err
			err.getReport
			pushMessage(pushbulletH)
		end
	end
	delete(parObj);
	
else % Serial porocessing
	
	for i = 1:nfolders
		try
			lesionParamsFile = [dataDir filesep folders{i}];
			files = listfiles('*_LesionParams.mat',lesionParamsFile);
			lesionParamsFile = [lesionParamsFile filesep files{1}];
			runLesionInsertionPlusRecon_WebApp(lesionParamsFile)
			pushMessage(pushbulletH)
		catch err
			err.getReport
			pushMessage(pushbulletH)
		end
	end
	
end

delete(pushbulletH);

end
