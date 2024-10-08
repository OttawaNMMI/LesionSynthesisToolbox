function [lesionImgData, lesions, refROI] = makeLesionImage(baselineImgData, lesionData, surroundingMargin)
% makeLesionImage - adds synthetic lesions to a baseline image.
%
% Usage:
% ======
%
% [lesionImgData, lesions, refROI] = makeLesionImage(baselineImgData, lesionData, surroundingMargin)
%
% Inputs:
%   baselineImgData, lesionData, surroundingMargin
% Outputs:
% ========
% lesionImgData - a structiure of the lesion image consisting of:
%   vol - the image volume as a binary. Units are as in hdr.image_units
%   hdr - a FlowQuant hdr structure
%
% See also: lesionSynthesisToolbox, applyUptakeUnits

% By Ran Klein, The Ottawa Hospital, 2019
% 2023-02-6 - added support for Bq/cc and SUV image units. Added comments.

% Sample the reference ROI PET activities from the baseline image
refROI = lesionData.refROI;
nRefROIs=length(refROI);
refROInames = cell(nRefROIs,1);
for ri=1:nRefROIs
	[refROI{ri}.PTintensity, refROI{ri}.map] = sampleROI(baselineImgData, refROI{ri});
	refROInames{ri} = refROI{ri}.name;
end

% scale the pixel size to the target simulated image matrix
fac = baselineImgData.hdr.xdim / lesionData.info.simParams.nXdim;

lesionImgData.hdr = baselineImgData.hdr;
lesionImgData.hdr.xdim = lesionData.info.simParams.nXdim;  % Clarification here - this is the size of the image for simulating the lesion, not what we are reconstructing (256)
lesionImgData.hdr.ydim = lesionData.info.simParams.nYdim;
lesionImgData.hdr.pix_mm_xy = lesionImgData.hdr.pix_mm_xy * fac;
lesionImgData.hdr.image_units = baselineImgData.hdr.image_units;

lesionImgData.vol = zeros([lesionImgData.hdr.xdim, lesionImgData.hdr.ydim, lesionImgData.hdr.nplanes]);
nLesions = length(lesionData.lesion);
lesions = cell(nLesions,1);
for li=1:nLesions
	lesion = lesionData.lesion{li};
	lesion.map = makeMap(lesionImgData.hdr, lesion, li, lesionData);
	lesion.baselineBackgroundPTintesity = sampleROI(baselineImgData, lesion);
	switch lesion.mode % TO DO - does background subtraction happen during simulation?
		case 'Lesion:Background'
			lesion.PTintensity = lesion.PTval * lesion.baselineBackgroundPTintesity;
			lesion.referencePTintensity = lesion.baselineBackgroundPTintesity;
		case 'Bq/cc'
			lesion.PTintensity = applyUptakeUnits(lesion.PTval, lesionImgData.hdr, [baselineImgData.hdr.image_units ' fixed']);
			switch baselineImgData.hdr.image_units(1)
				case 'k'
					lesion.referencePTintensity = lesion.referencePTintensity*1000;
				case 'M'
					lesion.referencePTintensity = lesion.referencePTintensity*1000000;
				case 'm'
					lesion.referencePTintensity = lesion.referencePTintensity/1000;
				case 'u'
					lesion.referencePTintensity = lesion.referencePTintensity/1000000;
			end
			lesion.referencePTintensity = 1; 
		case {'SUV','SUV-bw [g/mL],SUV_{bw}[g/mL]'}
			lesion.PTintensity = applyUptakeUnits(lesion.PTval, lesionImgData.hdr, [baselineImgData.hdr.image_units ' fixed']) / applyUptakeUnits(1, lesionImgData.hdr, 'SUV-bw [g/mL]');
			lesion.referencePTintensity = 1; 
		otherwise
			indx = strfind(lesion.mode,':');
			if length(indx) == 1
				ROIname1 = lesion.mode(indx+1:end);
				ri = find(strcmpi(ROIname1,refROInames));
				if length(ri) == 1
					lesion.PTintensity = lesion.PTval * refROI{ri}.PTintensity;
					lesion.referencePTintensity = refROI{ri}.PTintensity;
				else
					error(['Could not resolve a reference ROI named ' ROIname1])
				end
			else
				error(['Could not resolve lesion intensity mode' lesion.mode])
			end
	end
	if ~isfield(lesion,'PTadditionMode')
		lesion.PTadditionMode = 'Final (Homogenous)';
	end
	switch lesion.PTadditionMode
		case 'Incremental' % activity in addition to that already present in the patient
			lesionImgData.vol = lesionImgData.vol + lesion.PTintensity * lesion.map;
		case 'Final (Homogenous)' % activity after lesion sysnthesis
			background = baselineImgData.vol;
			background(lesion.map==0) = 0;
			lesionImgData.vol = lesionImgData.vol + lesion.PTintensity * lesion.map - background;
		case 'Final (Maintain Texture)'
			background = mean(baselineImgData.vol(lesion.map>0));
			lesionImgData.vol = lesionImgData.vol + (lesion.PTintensity - background) * lesion.map;
		otherwise
			error(['Unrecognized lesion additionMode property ' lesion.additionMode]);
	end
	
	% surrounding summary statistics
	if nargin<3 % TO DO: this assumes spheres, will need to accomodate other shapes when we get there.
		surroundingMargin = 20; % mm
	end
	surrounding = lesion;
	surrounding.shape = 'Empty Sphere (homo)';
	surrounding.rad2 = surrounding.rad + surroundingMargin;

	[lesion.baselineSurroundingPTintensity, ~, voxelVals] = sampleROI(baselineImgData, surrounding);
	lesion.baselineSurroundingPTnoise = std(voxelVals);
	lesion.baselineSurroundingPTmin = min(voxelVals);
	lesion.baselineSurroundingPTmax = max(voxelVals);
	
	lesions{li} = lesion;
end
end


function map = makeMap(hdr, ROI, li, lesionData)
if ~isfield(ROI,'locUnits')
	ROI.locUnits = 'pixel';
end
if strcmpi(ROI.locUnits, 'pixel')
	xyFac =  ROI.hdr.pix_mm_xy / hdr.pix_mm_xy;
	loc =  [ROI.loc(1)*xyFac, ROI.loc(2)*xyFac, ROI.loc(3)]; % TO DO: what if number of slices changes?
else
	loc = convertImgLocationUnits(hdr, ROI.loc, ROI.locUnits, 'pixel');
end

switch ROI.shape
	case 'Sphere (homo)'
		map = MakeSphere(hdr,...
			loc(1), loc(2), loc(3),...
			ROI.rad,...
			1);
	case 'Empty Sphere (homo)'
		map = MakeSphere(hdr,...
			loc(1), loc(2), loc(3),...
			ROI.rad2,...
			1) - ...
		MakeSphere(hdr,...
			loc(1), loc(2), loc(3),...
			ROI.rad,...
			1);
    case 'Blobby sphere (homo)'
        if isa(lesionData, 'struct')
            vars = lesionData.lesion{1,li}.var;
        else
            vars = 0;
        end
        map = MakeBlobbySphere(hdr,...
            loc(1), loc(2), loc(3),...
            ROI.rad,vars,...
            1);
        
	otherwise
		disp(['Unrecognized ROI shape ' ROI.shape])
end
end


function [intensity, map, voxelValues] = sampleROI(imgData, ROI)
map = makeMap(imgData.hdr, ROI, 1, 1);
voxelValues = imgData.vol(map>0);
intensity = mean(voxelValues);
end