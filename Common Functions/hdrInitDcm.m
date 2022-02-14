% hdrInitDcm - Initializes the image header info from the DICOM header.
%
% Usage:
% [hdr, infodcm] = hdrInitDcm(fname)
%
% Input arguments:
% fname - the filename of the DICOM file
%
% Output arguments:
% hdr - the proprietery header structure
% infodcm - the DICOM header structure
% messages - a cell of strings with returned messages
%
% See also: DCSInitCurrentData

% By Ran Klein August-2007
% University of Ottawa Heart Institute

% *******************************************************************************************************************
% *                                                                                                                 *
% * Copyright [2014] Ottawa Heart Institute Research Corporation.                                                   *
% * This software is confidential and may not be copied or distributed without the express written consent of the   *
% * Ottawa Heart Institute Research Corporation.                                                                    *
% *                                                                                                                 *
% *******************************************************************************************************************

function [hdr, infodcm, messages] = hdrInitDcm(fname)

messages = {};
if ischar(fname)
	dictfile = [fileparts(fileparts(mfilename('fullpath'))) filesep 'dicom-dict-truncated.txt'];
	if exist(dictfile,'file')
		dicomdict('set', dictfile)
	end
	if exist(fname,'dir')
		files = listfiles('*.*',fname);
		infodcm = dicominfo([fname filesep files{1}]);
	elseif exist(fname,'file')
		infodcm = dicominfo(fname);
	else
		error(['Could not resolve a DICOM file in ' fname])
	end
elseif isstruct(fname)
    infodcm = fname;
end

%% Date and Time
if isfield(infodcm,'SeriesDate')
	date = infodcm.SeriesDate;
elseif isfield(infodcm,'StudyDate')
	date = infodcm.StudyDate;
else
	date = '';
end
if isfield(infodcm,'SeriesTime')
	date = [date ' ' infodcm.SeriesTime];
elseif isfield(infodcm,'StudyTime')
	date = [date ' ' infodcm.StudyTime];
end
try
	date = datestr(datenum(date),0);
catch
	try
		date = datestr(datenum(date,'yyyymmdd HHMMSS'),0);
	catch
		% just keep the existing format
	end
end

%% Type of Image
seriesType = '';
if isfield(infodcm,'SeriesType')
	seriesType = infodcm.SeriesType;
elseif isfield(infodcm,'AcquisitionContextSequence') && isfield(infodcm.AcquisitionContextSequence,'Item_1')
	if isfield(infodcm.AcquisitionContextSequence.Item_1,'ConceptCodeSequence') && isfield(infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence,'Item_1')
		if isfield(infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence.Item_1,'CodingSchemeDesignator') && isfield(infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence.Item_1,'CodeValue')
			switch infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence.Item_1.CodingSchemeDesignator 
				case 'SRT'
					switch infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence.Item_1.CodeValue
						case 'F-01604', seriesType = 'Resting State';
						case 'P2-71310', seriesType = 'Exercise challenge';
						case 'P2-71317', seriesType = 'Drug Infusion Challenge';
					end
			end
		elseif isfield(infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence.Item_1,'CodeMeaning')
			seriesType = infodcm.AcquisitionContextSequence.Item_1.ConceptCodeSequence.Item_1.CodeMeaning;
		end
	end
end
if isempty(seriesType) && isfield(infodcm,'ProtocolName')
	seriesType = infodcm.ProtocolName;
end

%% Patient Info
patient_name = [];
if isfield(infodcm,'PatientName')
	if isfield(infodcm.PatientName,'FamilyName')
		patient_name = infodcm.PatientName.FamilyName;
	end
	if isfield(infodcm.PatientName,'GivenName')
		patient_name = [patient_name ' ' infodcm.PatientName.GivenName];
	end
end

if isfield(infodcm,'PatientBirthDate') && ~isempty(infodcm.PatientBirthDate)
	try
		patientDOB = datestr(datenum(infodcm.PatientBirthDate),0);
	catch
		patientDOB = datestr(datenum(infodcm.PatientBirthDate,'yyyymmdd'),0);
	end
else
	patientDOB = '';
end
if isfield(infodcm,'PatientSex')
	patientSex = resolveSex(infodcm.PatientSex);
else
	patientSex = '';
end
if isfield(infodcm,'PatientSize')
	patientHeight = infodcm.PatientSize; %meters
	if patientHeight> 3 % saved as cm ???
		patientHeight = patientHeight/100; % convert to meters
	end
 else
	patientHeight = nan;
end

if isfield(infodcm,'PatientWeight')
	patientWeight = infodcm.PatientWeight;
else
	patientWeight = nan;
end


%% Equipment info
if ~isfield(infodcm,'Manufacturer')
	infodcm.Manufacturer = '';
end
if ~isfield(infodcm,'ManufacturerModelName')
	infodcm.ManufacturerModelName = '';
	model_num = infodcm.Manufacturer;
else
	model_num = infodcm.ManufacturerModelName;
end



%% Determine the image resolution
if strcmpi(infodcm.Modality,'CT')
	resolution = infodcm.PixelSpacing(1);
elseif strcmpi(infodcm.Manufacturer, 'GE MEDICAL SYSTEMS') &&...
		isfield(infodcm,'Private_0009_10eb') % Possible private field containing smoothing in GE format
	if length(infodcm.Private_0009_10eb)==1
		resolution = infodcm.Private_0009_10eb;
	else % temporary fix for Hermes DICOm files that screw up the private field and represent a float value as a 4xint8 array
		resolution = 12;
	end
elseif isfield(infodcm,'ConvolutionKernel')
	Kresolution = infodcm.ConvolutionKernel;
	i = 1;
	start_i = 0;
	while i<=length(Kresolution) && ischar(Kresolution)
		if any(Kresolution(i)=='1234567890.')
			if start_i==0
				start_i=i;
			end
		elseif start_i~=0
			Kresolution = str2double( Kresolution(start_i:i-1) );
		end
		i = i+1;
	end
	if ischar(Kresolution) 
		if start_i~=0
			Kresolution = str2double( Kresolution(start_i:end) );
		else
			Kresolution = 0;
		end
	end

	Iresolution = intrinsicResolution(infodcm);
	resolution = sqrt(Kresolution^2 + Iresolution^2);
elseif ~isempty(infodcm.Manufacturer)
	resolution = intrinsicResolution(infodcm);
else
	messages = [messages; ('This file doesn''t even contain a manufacturer field!')];
	resolution = nan;
end

if isfield(infodcm,'ReconstructionMethod')
	reconstruction = infodcm.ReconstructionMethod;
elseif isfield(infodcm,'CardiacReconAlgorithm')
	reconstruction = infodcm.CardiacReconAlgorithm;
else
% 	disp('TO DO: Reconstruction field is not populated from dicom')
	reconstruction = '';
end

if isfield(infodcm,'SeriesDescription')
	study = infodcm.SeriesDescription;
else
	study = 'UnknownStudy';
% 	disp('TO DO: Study is not recovered from from dicom')
end

injectedActivity = nan;
if isfield(infodcm,'Modality') && strcmpi(infodcm.Modality,'CT')
	if isfield(infodcm,'ContrastBolusAgent')
		tracer = infodcm.ContrastBolusAgent;
	else
		tracer = 'CT';
	end
else
	try
		tracer = decodeTracerName(infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1);
	catch
		try % Perhaps just the code meaning is stored
			tracer = infodcm.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical;
		catch % use the isotope information
			try
				tracer = decodeTracerName(infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1);
			catch l
				if strcmpi(l.identifier,'MATLAB:nonExistentField')
					tracer = 'Unknown';
				else
					retrhow(l);
				end
			end
		end
	end
	if strcmpi(tracer,'Unknown')
		if isfield(infodcm,'Private_0009_1036') % GE toolbox intermediate files
			tracer = infodcm.Private_0009_1036;
		elseif isfield(infodcm,'EnergyWindowInformationSequence')
			if isfield(infodcm.EnergyWindowInformationSequence,'Item_1')
				tracer = infodcm.EnergyWindowInformationSequence.Item_1;
			else
				tracer = EnergyWindowInformationSequence;
			end
			if isfield(tracer,'EnergyWindowName')
				tracer = tracer.EnergyWindowName;
			else
				tracer = 'Unknown';
			end
		else
			tracer = 'Unknown';
		end
	end
	
	% injected activity decay corrected to scan start time
	try
		injectedDateTime = infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDatetime;
	catch
		try
			injectedDateTime = [datestr(date,'yyyymmdd') infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime(1:6)];
		catch
			try % GE toolbox intermediate files
				injectedDateTime = infodcm.Private_0009_103b;
			catch
			end
		end
	end
	
	try
		injectedActivity = infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose/1e6 *...
			exp(-log(2)/infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife * ... lambdah - time units = seconds
			(datenum(date) - datenum(injectedDateTime,'yyyymmddHHMMSS'))*24*60*60); % Time Elapsed
	catch
		try % GE toolbox intermediate files
			% Activity is decay corrected to imaging time
			injectedActivity = infodcm.Private_0009_1038 *...
				exp(-log(2)/infodcm.Private_0009_103f * ... lambdah - time units = seconds
				(datenum(date) - datenum(infodcm.Private_0009_1039,'yyyymmddHHMMSS'))*24*60*60)...
				- ...
				infodcm.Private_0009_103c *...
				exp(-log(2)/infodcm.Private_0009_103f * ... lambdah - time units = seconds
				(datenum(date) - datenum(infodcm.Private_0009_103d,'yyyymmddHHMMSS'))*24*60*60); % Time Elapsed
			injectedActivity = injectedActivity * infodcm.Private_0009_1040; % Positron branching fraction
		catch
		end
	end
end

if isfield(infodcm,'NumberOfTimeSlices') % dynamic study
	nframes = infodcm.NumberOfTimeSlices;
	imagetype = 'dynamic';
elseif isfield(infodcm,'NumberOfTimeSlots') % gated study
	nframes = infodcm.NumberOfTimeSlots;
	imagetype = 'gated';
elseif isfield(infodcm,'NumberOfPhases')
	nframes = infodcm.NumberOfPhases;
	imagetype = 'dynamic';
elseif strcmpi(infodcm.Manufacturer, 'GE MEDICAL SYSTEMS') &&...
		isfield(infodcm,'Private_0009_10e0') % Private field containing smoothing in GE format
	nframes = infodcm.Private_0009_10e0;
	imagetype = 'dynamic';
elseif strcmpi(infodcm.Manufacturer, 'TOSHIBA') &&...
		isfield(infodcm,'ScanOptions') && strcmpi(infodcm.ScanOptions,'DVOLUME_CT')
	nframes = infodcm.TemporalPositionIndex; % not the right field - but we know there are at least these many frames.
	imagetype = 'dynamic';
else % Neither dynamic nor gated
	nframes = 1;
	imagetype = 'static';
end

if isfield(infodcm,'NumberOfSlices')
	nplanes = double(infodcm.NumberOfSlices);
elseif isfield(infodcm,'NumberOfFrames')
	nplanes = infodcm.NumberOfFrames/nframes;
elseif strcmpi(infodcm.Manufacturer, 'GE MEDICAL SYSTEMS') &&...
		isfield(infodcm,'Private_0009_10df') % Private field containing smoothing in GE format
	nplanes = infodcm.Private_0009_10df;
else
	nplanes = nan;
% 	warning('Did not resolve number of planes');
end

transverseRotation = nan;
fields = {'PatientOrientationModifierCodeSequence','PatientOrientationCodeSequence'};
i = 1;
while isnan(transverseRotation) && i<=length(fields)
	field = fields{i};
	if isfield(infodcm,field) && isfield(infodcm.(field),'Item_1')
		if isfield(infodcm.(field).Item_1,'CodeMeaning')
			if strcmpi(infodcm.(field).Item_1.CodeMeaning,'recumbent')
				transverseRotation = 0;
			elseif strcmpi(infodcm.(field).Item_1.CodeMeaning,'supine')
				transverseRotation = 0;
			elseif strcmpi(infodcm.(field).Item_1.CodeMeaning,'right lateral decubitus')
				transverseRotation = -90;
			elseif strcmpi(infodcm.(field).Item_1.CodeMeaning,'left lateral decubitus')
				transverseRotation = 90;
			end
		elseif isfield(infodcm.(field).Item_1,'CodingSchemeDesignator') && isfield(infodcm.(field).Item_1,'CodeValue')
			if strcmpi(infodcm.(field).Item_1.CodingSchemeDesignator,'SNM3')
				if strcmpi(infodcm.(field).Item_1.CodeValue,'F-10450')
					transverseRotation = 0;
				elseif strcmpi(infodcm.(field).Item_1.CodeValue,'F-10340')
					transverseRotation = 0;
				elseif strcmpi(infodcm.(field).Item_1.CodeValue,'F-10317')
					transverseRotation = -90;
				elseif strcmpi(infodcm.(field).Item_1.CodeValue,'F-10319')
					transverseRotation = 90;
				end
			end % SNM3
		end
	end
	i = i+1;
end % while loop through possible fields
if isnan(transverseRotation)
	if isfield(infodcm,'PatientPosition')
		switch upper(infodcm.PatientPosition(3:end))
			case 'S'
				transverseRotation = 0;
			case 'P'
				transverseRotation = 0;
			case 'DL'
				transverseRotation = -90;
			case 'DR'
				transverseRotation = 90;
		end
	else
		transverseRotation = 0;
	end
end	

longitudeFlip = false;
if isfield(infodcm,'PatientGantryRelationshipCodeSequence') && isfield(infodcm.PatientGantryRelationshipCodeSequence,'Item_1')
	if isfield(infodcm.PatientGantryRelationshipCodeSequence.Item_1,'CodingSchemeDesignator') && isfield(infodcm.PatientGantryRelationshipCodeSequence.Item_1,'CodeValue')
		if strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodingSchemeDesignator,'SNM3') 
            if strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeValue,'F-10470')
                longitudeFlip = false;
            elseif strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeValue,'F-10480')
                longitudeFlip = true;
            end
        elseif strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodingSchemeDesignator,'SRT') %MiE Scintron data
            if strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeValue,'F-10480')
				longitudeFlip = true;
            end
        elseif strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodingSchemeDesignator,'99SDM')
			if strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeValue,'G-5190')
				longitudeFlip = false;
			elseif strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeValue,'G-5191')
				longitudeFlip = true;
			end
		end % SNM3
	elseif isfield(infodcm.PatientGantryRelationshipCodeSequence.Item_1,'CodeMeaning')
		if strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeMeaning,'headfirst')
			longitudeFlip = false;
		elseif strcmpi(infodcm.PatientGantryRelationshipCodeSequence.Item_1.CodeMeaning,'feetfirst')
			longitudeFlip = true;
		end
	end
elseif isfield(infodcm,'PatientPosition')
	if strcmpi(infodcm.PatientPosition(1:2),'FF')
		longitudeFlip = true;
	end
end

%08-04-2009 JR - added these cases to deal with London and Toronto SPECT images specifically
if isfield(infodcm,'Modality') 
	% 20-05-2013 - RK - Flipped images in Sao Paulo. Might be due to
	% transfer via Xceleris intermediate. But, FF patient position is correct.
	if strcmpi(infodcm.Modality,'PT')
        if strcmpi(infodcm.Manufacturer,'Philips Medical Systems')
            longitudeFlip = ~longitudeFlip;
        end
	elseif strcmpi(infodcm.Modality,'NM')
		if strcmpi(infodcm.ManufacturerModelName,'NuCARDIO')
			longitudeFlip = true; %for non-AC SPECT images from Toronto
		end
        if isfield(infodcm,'InstitutionName') && strcmpi(infodcm.InstitutionName,'SJ')
            longitudeFlip = false; %though the orientation is indicated as FFS for SPECT images from London
            %the data is stored in HFS orientation
        end
        if isfield(infodcm,'SourceApplicationEntityTitle') && ~isempty(strfind(infodcm.SourceApplicationEntityTitle,'TWH')) %for AC SPECT images from Toronto
            longitudeFlip = false;
        end
    elseif strcmpi(infodcm.Modality,'CT')
        if strcmpi(infodcm.Manufacturer,'GE MEDICAL SYSTEMS')
            if isfield(infodcm,'InstitutionName') && strcmpi(infodcm.InstitutionName,'Ottawa Heart Institute')
       			longitudeFlip = ~longitudeFlip;
            end
        end
	end
end

if (~isempty(strfind(infodcm.Manufacturer,'Bioscan')) || ~isempty(strfind(infodcm.Manufacturer,'Mediso'))) || ...
		strcmpi(infodcm.ManufacturerModelName,'NanoSPECT') || ...
		(strcmpi(infodcm.Manufacturer,'Siemens') && strcmpi(infodcm.ManufacturerModelName,'resw'))
	transverseRotation = transverseRotation + 180;
% 	longitudeFlip = ~longitudeFlip;
end

%% Spacing between z slices
if isfield(infodcm,'SpacingBetweenSlices')
	sliceSpacing = abs(infodcm.SpacingBetweenSlices); % make sure that not negative value
elseif isfield(infodcm,'SliceThickness')
	sliceSpacing = infodcm.SliceThickness;
else
	sliceSpacing = nan;
end

%% Image units
if isfield(infodcm,'Units')
	image_units = infodcm.Units;
else
	switch upper(infodcm.Modality)
		case 'CT'
			image_units = 'hu';
		otherwise
			image_units = 'Bq/cc';
	end
end
image_units = strrep(strtrim(image_units),' ','');
switch upper(image_units)
	case {'BQML','BQ/CC'}
		image_units = 'Bq/cc';
	case {'HU'}
		image_units = 'HU';
	otherwise
		messages = [messages; (['Unmanaged image units detected: ' image_units])];
end
	

%% Ensure missing fields are present
infodcm = completeStructData(infodcm,struct('PixelSpacing',nan,...
								  'PatientID','',...
								  'StudyID','',...
								  'ImagePositionPatient',[0 0 0]));
								  
hdr = struct('filename',fname,...
	'nframes',double(nframes),'nplanes',nplanes,'xdim',double(infodcm.Width),'ydim',double(infodcm.Height),...
	'pix_mm_xy',infodcm.PixelSpacing(1),'pix_mm_z',sliceSpacing,...
	'resolution',resolution,...
	'image_offset_mm', infodcm.ImagePositionPatient,...
	'reconstruction',reconstruction,...
	'frame_start',nan(nframes,1),'frame_len',nan(nframes,1),'quant_dynamic',nan(nframes,1),'image_units',image_units,...
	'PETTotalCounts',nan(nframes,1),'PrimaryPromptsCountsAccumulated',nan(nframes,1),'ScatterFractionFactor',nan(nframes,1),'DeadTimeFactor',nan(nframes,1),... 
	'nativefile',fname,'patient_name',patient_name,'patientID',infodcm.PatientID,'model_num',model_num,...
	'tracer',tracer,'study',study,'date',date,...
	'patientDOB',patientDOB,'patientSex',patientSex,'patientHeight',patientHeight,'patientWeight',patientWeight,'injectedActivity',injectedActivity,...
	'studyID',infodcm.StudyID,'StudyInstanceUID',infodcm.StudyInstanceUID,'examType',seriesType,'modality',infodcm.Modality,...
	'image_type',imagetype,'transverseRotation',transverseRotation,'longitudinalFlip',longitudeFlip);

%% Completes the fields in the data structure using the default data.
function data = completeStructData(data,defdata)

if ~isempty(defdata)
	if isempty(data)
		data = defdata;
	else
		fnames = fieldnames(defdata);
		for i = 1:length(fnames)
			if isstruct(defdata.(fnames{i})) % the field is a structure
				if isfield(data,fnames{i})
					data.(fnames{i}) = completeStructData(data.(fnames{i}),defdata.(fnames{i}));
				else
					data.(fnames{i}) = defdata.(fnames{i});
				end
			else
				if ~isfield(data,fnames{i}) || isempty(data.(fnames{i})) ||...
						(ischar(data.(fnames{i})) && (strcmpi(data.(fnames{i}),'Automatically Choose') ||...
						strcmpi(data.(fnames{i}),'Default Option') ||...
						strcmpi(data.(fnames{i}),'Default'))) % use default values
					data.(fnames{i}) = defdata.(fnames{i});
				end
			end % isstruct
		end % field loop
	end % isempty data
end

%% Intrinsic resolution is not recovered from DICOM - use lookup data
function imgResolution = intrinsicResolution(infodcm)

imgResolution = 6; % Default value
switch upper(infodcm.Manufacturer)
	case 'GE MEDICAL SYSTEMS'
		imgResolution = 7; %mm
	case 'SIEMENS'
		switch upper(infodcm.ManufacturerModelName)
			case {'1094','BIOGRAPH64'}
				imgResolution = 5;
		end
	case {'ADVANCED MOLECULAR IMAGING INC.','AMI'}
		imgResolution = 1.6; %mm
	case {'MEDISO'}
		imgResolution = 0; %mm
end

%% Determine the patient sex
function sex = resolveSex(str)
switch lower(str)
	case {'m','male'}
		sex = 'Male';
	case {'f','female'}
		sex = 'Female';
	otherwise
		sex = '';
end