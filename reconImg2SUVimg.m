%--------------------------------------------------------------------------
%
%							THE OTTAWA HOSPITAL
%						Division of Nuclear Medicine
%
%--------------------------------------------------------------------------
%
% reconImg2SUVimg m-file
%
% reconImg2SUVimg converts voxel units from REGRECON5 Toolbox output
% (bq/cc) into SUV-bw [g/mL] using hdr information pulled from DICOM RPDC &
% sinogram files from the console (GE DISCOVERY 710 - General Campus)
%
% Usage:		reconImg2SUVimg(fImg)
%				
%				fImg - [string] directory where reconstructed .sav file is
%                      archived
%
% Output [0]:   N/A
%				
%
% Developer		: HJUMA (hjuma@toh.ca)
% Date Created	: Aug 7 2019
% Last Edited	: 
% Edit Notes    : 
% Also See		: hdrinitdcm, ApplyUptakeUnits 
% View Online   : GE Discovery 710 Conformance Statement
%
% Notes			: 

function [img, hdr, uptakeUnits] = reconImg2SUVimg(fImg) 

if nargin < 1 
	warning('No input string for .sav file to search') 
	return
end

%img = readSavefile(fImg);
load(fImg)

% Break down the filename to resolve the PATH 
[p,~,~] = fileparts(fImg);

% Break down the PATH to resolve the RECONNAME
[~,f2,~] = fileparts(p); 

% Derive the LesionParams path and read in file 
fParams = [p filesep 'LesionParams_' f2 '.mat'];

% This file has the location of the target patient directory
if exist(fParams)
    
    load(fParams)
else
    info.patdatadir =  p;
end

% Derive path of dicom slice from recon image to read dicom info
pReconSlice = [info.patdatadir filesep 'WIN64_Perception_Recon_Offline_3D']; 
if ~exist(pReconSlice)
	pReconSlice = [info.patdatadir filesep 'Perception_Baseline_Recon_Offline_3D'];
end
if ~exist(pReconSlice)
	pReconSlice = [info.patdatadir filesep 'Baseline_Recon_Offline_3D'];
end
if ~exist(pReconSlice)
	pReconSlice = [info.patdatadir filesep 'Offline_3D'];
end
filesRS = listfiles('.sdcopen',pReconSlice);

if isempty(filesRS)
	disp('')
end 


if isempty(filesRS) 
	if exist([p filesep 'Synthetic_Lesion_Offline_3D'])
		pReconSlice = [p filesep 'Synthetic_Lesion_Offline_3D']; 
		filesRS = listfiles('.sdcopen',pReconSlice); 
	else 
		warning(['Could not resolve DIR: ' p])
		img = []; 
		hdr = []; 
		uptakeUnits = 'failed'; 
		return 
	end
	
	if isempty(filesRS) 
		if exist(info.patdatadir)
			
		else
			[t1,t2,t3] = fileparts(info.patdatadir); 
			tpath = 'C:\temp\Discovery_DR\Clean Liver Recons'; 
			if exist([tpath filesep t2])
				info.patdatadir = [tpath filesep t2]; 
			end 
		end
		filesRS = listfiles('.1',[info.patdatadir filesep 'raw']);
		[hdr, dcmInfo] = hdrinitdcm([info.patdatadir filesep,...
			'raw',filesep, filesRS{1}]); 
	end 
	
else 
	% Populate FlowQuant/Dicominfo hdr from single DICOM recon slice
	[hdr, dcmInfo] = hdrinitdcm([pReconSlice filesep filesRS{1}]);
end 
 
if ~exist('dcmInfo')
	[hdr, dcmInfo] = hdrinitdcm([pReconSlice filesep filesRS{1}]);
end 


% Add missing feilds into FlowQuant hdr from Dicominfo header
% dont need to be in HDR 
hdr.tracer = dcmInfo.Private_0009_1036; 
hdr.tracer_activity = dcmInfo.Private_0009_1038; 
hdr.tracer_halfLife = dcmInfo.Private_0009_103f; 
hdr.meas_datetime = dcmInfo.Private_0009_1039; 
hdr.admin_datetime = dcmInfo.Private_0009_103b; 
hdr.post_inj_activity = dcmInfo.Private_0009_103c; 
hdr.post_inj_datetime = dcmInfo.Private_0009_103d; 

% Total dose calc 
% dont need to be in HDR
L = log(2)/hdr.tracer_halfLife; % lambdah - time units = seconds

hdr.TotalDose = (hdr.tracer_activity * exp(-L*...
    (datenum(hdr.meas_datetime,'yyyymmddHHMMSS')...
    -datenum(hdr.admin_datetime,'yyyymmddHHMMSS'))*24*60*60))...
    -(hdr.post_inj_activity * exp(-L*...
    (datenum(hdr.post_inj_datetime,'yyyymmddHHMMSS')...
    -datenum(hdr.admin_datetime,'yyyymmddHHMMSS'))*24*60*60)); % MBq 

% Injected Activity calc (keep this in HDR) 
hdr.injectedActivity = hdr.TotalDose *...
	exp(-L * ... 
	(datenum(hdr.date) - datenum(hdr.admin_datetime,'yyyymmddHHMMSS'))*24*60*60); %MBq

% Convert to SUV 
[img, uptakeUnits, ~, status] = applyUptakeUnits(img, hdr, 'SUV-bw [g/mL]'); 
end 