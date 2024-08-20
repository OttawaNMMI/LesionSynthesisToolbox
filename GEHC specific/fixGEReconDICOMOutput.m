% fixGEReconDICOMOutput - appends missing data to the DICOM files produced
% by GE Recon.
% 
% Includes:
%  - Radiopharmaceutical information (type and activity)
%
% Can also be used to overwrite header information and anonymize the 
% patient identifiers
%
% Usage:
% fixGEReconDICOMOutput(dirIn, dirOut) - complete the missing information
% in place (overwiting source files).
% fixGEReconDICOMOutput(dirIn, dirOut) - complete the missing information
% in the input directory and save to the output directory.
% fixGEReconDICOMOutput(dirIn, dirOut, hdrOverwriteIn) - also overwrite
% header information with those specified in hdrOverwiteIn.
% fixGEReconDICOMOutput(dirIn, dirOut, hdrOverwriteIn, anonFlag) - also
% anonymize the patient identifiers using defualts.

function fixGEReconDICOMOutput(dirIn, dirOut, hdrOverwriteIn, anonFlag)

if nargin<1
	dirIn = pwd;
end
if nargin<2
% 	dirOut = [dirIn filesep 'Anon'];
	dirOut = dirIn;
end

if nargin<4
	anonFlag = false;
end

files = listfiles('*.*',dirIn);
if isempty(files)
	% empty input directory - do not proceed
	return
end
nfiles = length(files);
exts = cell(nfiles,1);
for i=1:nfiles
	[~,~,exts{i}] = fileparts(files{i});
end
[ext, ia, ic] = unique(exts);
if length(ext) == nfiles
	% assume extension is the file index number
else
	% characteristic file extension - ignore non-matching extensions
	count = zeros(length(ia),1);
	for i = 1:length(ia)
		count(i) = sum(ic == i);
	end
	i = find(count == max(count));
	files = files(ic == i);
	ext = ext{i};
	disp(['DICOM file extentions are ' ext])
	nfiles = length(files);
end

if exist(dirOut,'dir')~=7
	mkdir(dirOut);
end

for filei = 1:nfiles
	
	file = [dirIn filesep files{filei}];
	
	prevDICOMDict = dicomdict("get");
	dicomdict("set","pet-dicom-dict.txt")
	infodcm = dicominfo(file);
	img = dicomread(infodcm);
	
	if filei==1
		% figure out new header values using the first file
		% Default values to replace
		
		if anonFlag % TO DO: not tested
			hdrOverwrite.PatientName = struct('FamilyName','Anon',...
				'GivenName','Anon');
			hdrOverwrite.PatientID = '00000000';
			hdrOverwrite.PatientBirthDate = 'YYYY0101';
			hdrOverwrite.ReferringPhysicianName = struct('FamilyName','',...
				'GivenName','');
			hdrOverwrite.OperatorName.FamilyName = '';
			hdrOverwrite.PhysicianReadingStudy = struct('FamilyName', '',...
				'GivenName', '',...
				'MiddleName', '',...
				'NamePrefix', '',...
				'NameSuffix', '');
			hdrOverwrite.AdditionalPatientHistory = '';
		
		end
		% Radiophamaceutical info for SUV display
		if isfield(infodcm,'tracer_activity') % using Ge dictionary
			injectedActivity = infodcm.tracer_activity - ...
				infodcm.post_inj_activity *...
				exp(-log(2)/infodcm.half_life * ... lambdah - time units = seconds
				(datenum(infodcm.meas_datetime,'yyyymmddHHMMSS') - datenum(infodcm.post_inj_datetime,'yyyymmddHHMMSS'))*24*60*60); % Time Elapsed
			injectedActivity = injectedActivity * 10^6; 
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical = infodcm.tracer_name;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime = infodcm.admin_datetime(9:end);
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopTime = infodcm.post_inj_datetime(9:end);
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = injectedActivity;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = infodcm.half_life;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclidePositronFraction = infodcm.positron_fraction;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDatetime = infodcm.admin_datetime;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopDatetime = infodcm.post_inj_datetime;		
		else % using a generic dictionary
			injectedActivity = infodcm.Private_0009_1038 - ...
				infodcm.Private_0009_103c *...
				exp(-log(2)/infodcm.Private_0009_103f * ... lambdah - time units = seconds
				(datenum(infodcm.Private_0009_1039,'yyyymmddHHMMSS') - datenum(infodcm.Private_0009_103d,'yyyymmddHHMMSS'))*24*60*60); % Time Elapsed
			injectedActivity = injectedActivity * 10^6; 
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical = infodcm.Private_0009_1036;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime = infodcm.Private_0009_103b(9:end);
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopTime = infodcm.Private_0009_103d(9:end);
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = injectedActivity;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = infodcm.Private_0009_103f;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclidePositronFraction = infodcm.Private_0009_1040;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDatetime = infodcm.Private_0009_103b;
			hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStopDatetime = infodcm.Private_0009_103d;
			% TO DO : there are tons of other unpopulated fields that need to be transcribed/derived from private fields
			%         hdrOverwrite.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence =
			%             <IdentifyingGroupLength size="4" element="0000" group="0008" htype="DCM">48</IdentifyingGroupLength>
			%             <CodeValue size="8" element="0100" group="0008" htype="DCM">C-111A1</CodeValue>
			%             <CodingSchemeDesignator size="4" element="0102" group="0008" htype="DCM">SRT</CodingSchemeDesignator>
			%             <CodeMeaning size="12" element="0104" group="0008" htype="DCM">^18^Fluorine</CodeMeaning>
			%         </RadionuclideCodeSequence>
			%         <RadiopharmaceuticalCodeSequence size="88" element="0304" group="0054" htype="HSQ">
			%             <IdentifyingGroupLength size="4" element="0000" group="0008" htype="DCM">60</IdentifyingGroupLength>
			%             <CodeValue size="8" element="0100" group="0008" htype="DCM">C-B1031</CodeValue>
			%             <CodingSchemeDesignator size="4" element="0102" group="0008" htype="DCM">SRT</CodingSchemeDesignator>
			%             <CodeMeaning size="24" element="0104" group="0008" htype="DCM">Fluorodeoxyglucose F^18^</CodeMeaning>
			%
		end
		if nargin>=3
			hdrOverwrite = completeStructData(hdrOverwriteIn, hdrOverwrite);
		end
	end
	
	[infodcm, hdrOverwrite] = replaceFields(infodcm, hdrOverwrite);
	
	dicomwrite(img, [dirOut filesep files{filei}] ,infodcm,'CreateMode','Copy','WritePrivate',true, 'UseMetadataBitDepths',true,'VR','explicit');
	dicomdict("set",prevDICOMDict);
end


function [infodcm, hdrOverwrite] = replaceFields(infodcm, hdrOverwrite)

fields = fieldnames(hdrOverwrite);

for fi = 1:length(fields)
	field = fields{fi};
	if isstruct(hdrOverwrite.(field))
		if isfield(infodcm,field)
			[infodcm.(field), hdrOverwrite.(field)] = replaceFields(infodcm.(field), hdrOverwrite.(field));
		else
			infodcm.(field) = hdrOverwrite.(field);
		end
	else
		if contains(field,'Date')
			date = hdrOverwrite.(field);
			dateMask = (date>='a' & date<='z') | (date>='A' & date<='Z');
			date(dateMask) = datestr(datenum(infodcm.(fname),'yyyymmdd'), hdrOverwrite.(field)(dateMask));
			hdrOverwrite.(field) = date;
		end
		if strcmp(hdrOverwrite.(field), 'DELETE')
			infodcm = rmfield(infodcm, field);
		else
			infodcm.(field) = hdrOverwrite.(field);
		end
	end
end

