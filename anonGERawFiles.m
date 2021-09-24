function anonGERawFiles(dir, newHdr, targetDir, progressBar)

if nargin<3
	targetDir = [dir 'anon'];
end

if exist(targetDir,'dir')~=7
	mkdir(targetDir)
	mkdir([targetDir filesep 'raw'])
	mkdir([targetDir filesep 'CTAC'])
end

defNewHdr.PatientName = struct('FamilyName','Anon',...
	'GivenName','Anon');
defNewHdr.PatientID = '00000000';
defNewHdr.PatientBirthDate = 'YYYY0101';
defNewHdr.ReferringPhysicianName = struct('FamilyName','',...
	'GivenName','');
defNewHdr.OperatorName = struct('FamilyName','',...
	'GivenName','');
defNewHdr.PhysicianReadingStudy = struct('FamilyName', '',...
	'GivenName', '',...
	'MiddleName', '',...
	'NamePrefix', '',...
	'NameSuffix', '');
defNewHdr.AdditionalPatientHistory = '';

keepFields = {'InstanceCreatorUID',... (0008,0014)
	'SOPInstanceUID',... (0008,0018)
	'AccessionNumber',... (0008,0050)
	'InstitutionName',... (0008,0080)
	'StationName',... (0008,1010)
	'StudyDescription',... (0008,1030)
	'SeriesDescription',... (0008,103E)
	'InstitutionalDepartmentName',... (0008,1040)
	'OperatorName',... (0008,1070)
	'ReferencedSOPInstanceUID',... (0008,1155)
	'PatientSex',... (0010,0040)
	'PatientAge',... (0010,1010)
	'PatientSize',... (0010,1020)
	'PatientWeight',... (0010,1030)
	'ProtocolName',... (0018,1030)
	'StudyInstanceUID',... (0020,000D)
	'SeriesInstanceUID',... (0020,000E)
	'StudyID',... (0020,0010)
	'FrameOfReferenceUID',... (0020,0052)
	'SynchronizationFrameOfReferenceUID',... (0020,0200) Image Comments (0020,4000)
	'Request Attributes Sequence'... (0040,0275)
	};

if nargin<2
	newHdr = defNewHdr;
else
	newHdr = completeStructData(newHdr, defNewHdr);
end

fields = fieldnames(newHdr);
nfields = length(fields);

sourceHdr = [];


if nargin>=4
	progressBar.Message = 'Anonymizing RPDC files';
end
% Raw PET data
files = listfiles('*.RPDC.*',[dir filesep 'raw']);
nfiles = length(files);
for fi=1:nfiles
	if nargin>=4
		progressBar.Value = 0.1 * fi/nfiles;
	end
	disp(files{fi})
	switch 3
		case 1 % TO DO: did not test using dicom dictionary
			info = dicominfo([dir filesep 'raw' filesep files{fi}],'dictionary','pet-dicom-dict.txt');
			for i = 1:nfields
				if isfield(info, fields{i})
					if ~isfield(sourceHdr,fields{i})
						sourceHdr.(fields{i}) = info.(fields{i});
					elseif ~isequal(sourceHdr.(fields{i}), info.(fields{i}))
						disp([' - Warning mismatching metadata for ' fields{i}])
						disp(sourceHdr.(fields{i}))
						disp(info.(fields{i}))
					end
					if contains(fields{i},'Date')
						date = newHdr.(fields{i});
						dateMask = (date>='a' & date<='z') | (date>='A' & date<='Z');
						date(dateMask) = datestr(datenum(info.(fields{i}),'yyyymmdd'),newHdr.(fields{i})(dateMask));
						newHdr.(fields{i}) = date;
					end
					info.(fields{i}) = newHdr.(fields{i});
				else
					disp([' - Missing field: ' fields{i}])
				end
			end
			status = dicomwrite(dicomread(info),[targetDir filesep 'raw' filesep files{fi}],info,'CreateMode','copy','WritePrivate',true,'UseMetadataBitDepth',true,'VR','explicit','dictionary','pet-dicom-dict.txt');
		case 2 
			dicomanon([dir filesep 'raw' filesep files{fi}], [targetDir filesep 'raw' filesep files{fi}], 'keep',keepFields, 'update',newHdr, 'WritePrivate',true,'UseVRHeuristic',false);
			info = dicominfo([dir filesep 'raw' filesep files{fi}],'dictionary','pet-dicom-dict.txt');
			infoanon = dicominfo([targetDir filesep 'raw' filesep files{fi}],'dictionary','pet-dicom-dict.txt');
		case 3 % Substitutes dat directly in the binary data and updates group lenghts
			info = dicominfo([dir filesep 'raw' filesep files{fi}]);
			fId = fopen([dir filesep 'raw' filesep files{fi}],'r');
			d = fread(fId, inf, '*uchar')';
			fclose(fId);
			for i = 1:nfields
				if isfield(info, fields{i})
					if ~isfield(sourceHdr,fields{i})
						sourceHdr.(fields{i}) = info.(fields{i});
					elseif ~isequal(sourceHdr.(fields{i}), info.(fields{i}))
						disp([' - Warning mismatching metadata for ' fields{i}])
						disp(sourceHdr.(fields{i}))
						disp(info.(fields{i}))
					end
					if contains(fields{i},'Date')
						date = newHdr.(fields{i});
						dateMask = (date>='a' & date<='z') | (date>='A' & date<='Z');
						date(dateMask) = datestr(datenum(info.(fields{i}),'yyyymmdd'),newHdr.(fields{i})(dateMask));
						newHdr.(fields{i}) = date;
					end
					if isstruct(info.(fields{i}))
						if isfield(info.(fields{i}),'MiddleName')
							d = mystrrep(d, [info.(fields{i}).FamilyName '^' info.(fields{i}).GivenName '^' info.(fields{i}).MiddleName], [newHdr.(fields{i}).FamilyName '^' newHdr.(fields{i}).GivenName], true);
						elseif isfield(info.(fields{i}),'GivenName')
							d = mystrrep(d, [info.(fields{i}).FamilyName '^' info.(fields{i}).GivenName], [newHdr.(fields{i}).FamilyName '^' newHdr.(fields{i}).GivenName], true);
						else
							d = mystrrep(d, info.(fields{i}).FamilyName, newHdr.(fields{i}).FamilyName, true);
						end
					else
						d = mystrrep(d, info.(fields{i}), newHdr.(fields{i}), true);
					end
				else
					disp([' - Missing field: ' fields{i}])
				end
			end
			fId = fopen([targetDir filesep 'raw' filesep files{fi}],'w');
			fwrite(fId, d, '*uchar');
			fclose(fId);
	end
	
	% debug
% 	infoanon = dicominfo([targetDir filesep 'raw' filesep files{fi}]);
% 	compareStructs(info, infoanon)

end


% SINO files
if nargin>=4
	progressBar.Message = 'Anonymizing SINO files';
end
repStrings = getRepStrings(sourceHdr, newHdr);
files = listfiles('SINO*.',[dir filesep 'raw']);
nfiles = length(files);
for fi=1:nfiles
	if nargin>=4
		progressBar.Value = 0.1 +0.1 * fi/nfiles;
	end
	disp(files{fi})
	fId = fopen([dir filesep 'raw' filesep files{fi}],'r');
	d = fread(fId,inf,'*uchar')';
	fclose(fId);
	for i=1:size(repStrings,1)
		d = mystrrep(d,repStrings{i,1},repStrings{i,2}, false);
	end
	fId = fopen([targetDir filesep 'raw' filesep  files{fi}],'w');
	fwrite(fId,d,'*uchar');
	fclose(fId);
end


%% CT data
if nargin>=4
	progressBar.Message = 'Anonymizing CTAC files';
end
files = listfiles('*.CTDC.*',[dir filesep 'CTAC']);
nfiles = length(files);
for fi=1:nfiles
	if nargin>=4
		progressBar.Value = 0.2 +0.8 * fi/nfiles;
	end
	disp(files{fi})
	info = dicominfo([dir filesep 'CTAC' filesep files{fi}]);
	for i = 1:nfields
		if isfield(info, fields{i})
			if ~isfield(sourceHdr,fields{i})
				sourceHdr.(fields{i}) = info.(fields{i});
			elseif ~isequal(sourceHdr.(fields{i}), info.(fields{i}))
				disp([' - Warning mismatching metadata for ' fields{i}])
				disp(sourceHdr.(fields{i}))
				disp(info.(fields{i}))
			end
			if contains(fields{i},'Date')
				date = newHdr.(fields{i});
				dateMask = (date>='a' & date<='z') | (date>='A' & date<='Z');
				date(dateMask) = datestr(datenum(info.(fields{i}),'yyyymmdd'),newHdr.(fields{i})(dateMask));
				info.(fields{i}) = date;
			else
				info.(fields{i}) = newHdr.(fields{i});
			end
		else
			disp([' - Missing field: ' fields{i}])
		end
	end
	status = dicomwrite(dicomread(info),[targetDir filesep 'CTAC' filesep files{fi}],info,'CreateMode','copy','WritePrivate',true);
end

dir2 = 'CT';
if exist([dir filesep dir2],'dir')==7
	mkdir([targetDir filesep 'CT'])
	if nargin>=4
		progressBar.Message = 'Anonymizing CT files';
	end
	files = listfiles('*.CTDC.*',[dir filesep dir2]);
	nfiles = length(files);
	for fi=1:nfiles
		if nargin>=4
			progressBar.Value = 0.2 +0.8 * fi/nfiles;
		end
		disp(files{fi})
		info = dicominfo([dir filesep dir2 filesep files{fi}]);
		for i = 1:nfields
			if isfield(info, fields{i})
				if ~isfield(sourceHdr,fields{i})
					sourceHdr.(fields{i}) = info.(fields{i});
				elseif ~isequal(sourceHdr.(fields{i}), info.(fields{i}))
					disp([' - Warning mismatching metadata for ' fields{i}])
					disp(sourceHdr.(fields{i}))
					disp(info.(fields{i}))
				end
				if contains(fields{i},'Date')
					date = newHdr.(fields{i});
					dateMask = (date>='a' & date<='z') | (date>='A' & date<='Z');
					date(dateMask) = datestr(datenum(info.(fields{i}),'yyyymmdd'),newHdr.(fields{i})(dateMask));
					info.(fields{i}) = date;
				else
					info.(fields{i}) = newHdr.(fields{i});
				end
			else
				disp([' - Missing field: ' fields{i}])
			end
		end
		status = dicomwrite(dicomread(info),[targetDir filesep dir2 filesep files{fi}],info,'CreateMode','copy','WritePrivate',true);
	end
end

if nargin>=4
	progressBar.Message = 'Copying geometry and normalization files';
end
%% Normalization and geometry files
copyfile([dir filesep 'geo3d.'], targetDir);
copyfile([dir filesep 'norm3d.'], targetDir);

end

% ============================================================================
%% Supporting functions

function repStrings = getRepStrings(sourceHdr, newHdr)
fields = fieldnames(sourceHdr);
nfields = length(fields);
repStrings = cell(0);
for i=1:nfields
	if isstruct(sourceHdr.(fields{i}))
		if strcmp(fields{i},'PatientName') || strcmp(fields{i},'ReferringPhysicianName')
			sourceStr = sourceHdr.(fields{i}).FamilyName;
			targetStr = newHdr.(fields{i}).FamilyName;
			if isfield(sourceHdr.(fields{i}),'GivenName')
				sourceStr = [sourceStr '^' sourceHdr.(fields{i}).GivenName];
				targetStr = [targetStr '^' newHdr.(fields{i}).GivenName];
			end
			if isfield(sourceHdr.(fields{i}),'MiddleName')
				sourceStr = [sourceStr '^' sourceHdr.(fields{i}).MiddleName];
			end
			repStrings = [repStrings;...
				{sourceStr, targetStr}];
		else
			repStrings = [repStrings; getRepStrings(sourceHdr.(fields{i}), newHdr.(fields{i}))];
		end
	else
		if length(sourceHdr.(fields{i}))>5
			repStrings = [repStrings; {sourceHdr.(fields{i}), newHdr.(fields{i})}];
		end
	end
end

end



function d = mystrrep(d, pat, newstr, updateGroupLength)
if updateGroupLength
	if length(pat)>4
		indx = strfind(d,pat);
		disp([' - Found ' pat ' at ' num2str(indx)])
		for j=1:length(indx)
			fieldLengthDiff = length(newstr) - length(pat);
			fieldLength = d(indx(j)-1)*256+d(indx(j)-2) + fieldLengthDiff;
			d = [d(1:indx(j)-3) uint8([mod(fieldLength,256) floor(fieldLength/256)]) uint8(newstr) (d(indx(j)+length(pat):end))];
			indx(j+1:end) = indx(j+1:end) + fieldLengthDiff; % subsequent indices will be shifted
			group = d(indx(j)-8 + (0:1));
			indxg = strfind(d(1:indx(j)),[group uint8([0 0]) 'UL' uint8([04 00])]);
			if isempty(indxg)
				disp('Could not find a group length variable')
			else
				disp(['    - Found group ' dec2hex(group(2),2) dec2hex(group(1),2) ' at ' num2str(indxg)])
				str = d(indxg+8 + (0:3));
				len = 0;
				for i=length(str):-1:1
					len = len*256+double(str(i));
				end
				len = len + fieldLengthDiff;
				str = uint8([0 0 0 0]);
				for i=1:4
					str(i) = uint8(mod(len,256));
					len = floor(len/256);
				end
				d(indxg+8 + (0:3)) = str;
			end
		end
	end
	
else % replace by the exact same length value
	if length(pat)>4
		indx = strfind(d,pat);
		disp([' - Found ' pat ' at ' num2str(indx)])
		for j=1:length(indx)
			len = max(length(pat),length(newstr));
			str = [newstr zeros(1,max(0, length(pat) - length(newstr)))];
			d(indx(j)+(0:len-1)) = str;
		end
	end
end
end

