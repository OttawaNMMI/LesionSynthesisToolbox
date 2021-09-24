%% Things to do 
% Documentation header 
% tables instead of cells

function DiscoveryDR_SC(updateDRclients,MRN2SearchDir)

% Where all the data is on the scanner
consoleDB = '/usr/g/sdc_image_pool/images/';

% Local Database Directory
localDB = 'C:\Users\hjuma\Documents\MATLAB\Lesion Synthesis Toolbox\DiscoveryDR Client and Source';

% Scanner log in credentials
host = '10.244.171.23';
user = 'ctuser';
pass = '4$apps';

% Make FTP connection
ftpobj = ftp(host,user,pass);

if updateDRclients
	[ConsoleDataList] = getConsoleDataList(ftpobj,consoleDB,localDB);
else
	load([localDB filesep 'GE710_Console_Data_List.mat'])
end

% Debugging only - not necessary 
sMRN = '40754491';
%data = xlsread([localDB filesep 'MRN2Search.xlsx']);

data = xlsread(MRN2SearchDir);

MRN2Search = data(:,1); % Grab the first column

for i = 1:length(MRN2Search)
	sMRN = num2str(MRN2Search(i));
	importDiscoveryData(sMRN, ConsoleDataList, localDB, consoleDB, ftpobj)
end

end

function importDiscoveryData(sMRN, ConsoleDataList, localDB, consoleDB, ftpobj)
for i = 1:length(ConsoleDataList(:,2))
	
	MRN = ConsoleDataList(i,2);
	
	if strfind(MRN{:},sMRN)
		disp('Found it')
		disp(num2str(i))
		flder2get = ConsoleDataList{i,1};
		
		cd(ftpobj,[consoleDB '/' flder2get]);
		
		inflder = dir(ftpobj);
		
		cd(ftpobj,[consoleDB '/' flder2get '/' inflder.name]);
		
		aflder = dir(ftpobj);
		
		j = 1;
		l = 1;
		
		for k = 1:length(aflder)
			cd(ftpobj,[consoleDB '/' flder2get '/' inflder.name '/' aflder(k).name]);
			files = dir(ftpobj);
			
			if ~isempty(strfind(files(1).name,'CTDC'))
				CTDC{j} = aflder(k).name;
				nCTDC(j) = length(files);
				j = j + 1;
			end
			
			if  ~isempty(strfind(files(1).name,'RPDC'))
				RPDC{l} = aflder(k).name;
				nRPDC(l) = length(files);
				l = l + 1;
			end
		end
		
		nbedpos = nRPDC - 3; % WellCounter/Norm/Geo3D
		
		if nbedpos == 8
			eslices = 299;
		elseif nbedpos == 7
			eslices = 263;
		else
			eslices = 0;
		end
		
		if eslices
			for k = 1:length(nCTDC)
				if nCTDC(k) == eslices
					CTDC = CTDC(k);
				end
			end
		end
		
		MRN = MRN{:};
		
		mkdir(localDB,MRN);
		
		if length(CTDC) < 2
			
			CTDC = CTDC{:};
			
			mkdir([localDB filesep MRN],'CTAC');
			
			cd(ftpobj,[consoleDB '/' flder2get '/' inflder.name '/' CTDC]);
			files2get = ftpobj.dir;
			
			for k = 1:length(files2get)
				mget(ftpobj,files2get(k).name,[localDB filesep MRN filesep,'CTAC'])
			end
			
			mkdir([localDB filesep MRN],'raw');
			
			studydir = [consoleDB '/' flder2get '/' inflder.name '/' RPDC{:}];
			
			cd(ftpobj,studydir);
			files2get = ftpobj.dir;
			
			for k = 1:length(files2get)
				cd(ftpobj,studydir);
				
				mget(ftpobj,files2get(k).name,[localDB filesep MRN filesep,'raw']);
				
				tmp = [localDB filesep MRN filesep 'raw' filesep files2get(k).name];
				info = dicominfo(tmp);
				
				if isfield(info,'Private_0009_10e4')
					if strfind(info.Private_0009_10e4,'WB')
						sino = info.Private_0009_1062;
						[p f e] = fileparts(sino);
						cd(ftpobj,p);
						mget(ftpobj,f,[localDB filesep MRN filesep 'raw']);
					end
				elseif  isfield(info,'Private_0019_1007')
					if strfind(info.Private_0019_1007,'well counter')
						%disp('Well Counter Calibration File Found')
						%info.Private_0019_1007
					end
				elseif  isfield(info,'Private_0017_1005')
					if strfind(info.Private_0017_1005,'3D Geometric Calibration')
						geo3d = info.Private_0017_1007;
						[p f e] = fileparts(geo3d);
						cd(ftpobj,p);
						mget(ftpobj,f,[localDB filesep MRN]);
						movefile([localDB filesep MRN filesep f],[localDB filesep MRN filesep 'geo3d'])
						%disp('3D Geometric Calibration File Found')
					else strfind(info.Private_0017_1005,'PET 3D Normalization')
						norm3d = info.Private_0017_1007;
						[p f e] = fileparts(norm3d);
						cd(ftpobj,p);
						mget(ftpobj,f,[localDB filesep MRN]);
						movefile([localDB filesep MRN filesep f],[localDB filesep MRN filesep 'norm3d'])
					end
					
				end
				
			end
		else
			%cd(ftpobj,[consoleDB])
			%mget(ftpobj,flder2get,[localDB filesep MRN])
			disp(['Organization of GE PETRECON Toolbox Directory Style Failed. Manual Retreieve Required'])
		end
	end
end
end

function [ConsoleDataList] = getConsoleDataList(ftpobj,consoleDB,localDB)
% Get into directory with all the data
cd(ftpobj,consoleDB)

% Grab all the folders
data = dir(ftpobj);

for i = 1:size(data,1)
	folders{i} = data(i).name;
end

disp(['Found ' num2str(length(folders)) ' Studies'])
for i = 1:length(folders) % num patients
	
	% Get into patient DIR
	cd(ftpobj,[consoleDB '/'  folders{i}]);
	
	patstudies = dir(ftpobj);
	dFolder{i} = folders{i};
	
	for k = 1:length(patstudies)
		%disp('Skipped')
		Names{i} = 'Multi-Scan-Study';
		IDs{i} = '000000';
		Date{i} = '00/00/00';
		
		
		fname = patstudies(k).name;
		cd(ftpobj,[consoleDB '/'  folders{i} '/'  fname]);
		sstudy = dir( ftpobj);
		
		for j = 1:length(sstudy)
			cd( ftpobj,[ consoleDB '/' folders{i} '/' fname,...
				'/' sstudy(j).name]);
			% Search for CT file (since its the smallest)
			tempdata = dir( ftpobj);
			if strfind(tempdata(1).name,'.CTDC')
				%disp('found CT')
				temp = mget( ftpobj,tempdata(1).name);
				dicomhdr = dicominfo(temp{1});
				IDs{i} = dicomhdr.PatientID;
				Date{i} = dicomhdr.AcquisitionDate;
				if isfield(dicomhdr.PatientName,'GivenName') && isfield(dicomhdr.PatientName,'FamilyName')
					Names{i} = [dicomhdr.PatientName.GivenName '  ' dicomhdr.PatientName.FamilyName];
					
					if exist(temp{:})
						delete(temp{:})
					end 
				end
				
				break
				
			end
		end
		
		break;
		
	end	
	i
end

% Consolidate Data
ConsoleDataList = [dFolder', IDs', Names', Date'];

% Save current scanner data
name = [localDB filesep 'GE710_Console_Data_List'];
save([name '.mat'],'ConsoleDataList')
end