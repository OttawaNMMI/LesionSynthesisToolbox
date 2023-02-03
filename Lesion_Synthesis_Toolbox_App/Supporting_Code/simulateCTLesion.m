function [lesionImgData, lesions] = simulateCTLesion(baselineImgData, lesionData, surroundingMargin)

% Reference regions not implemented for CT lesion intensity
% % Sample the reference ROI PET activities from the baseline image
% refROI = lesionData.refROI;
% nRefROIs=length(refROI);
% refROInames = cell(nRefROIs,1);
% for ri=1:nRefROIs
% 	[refROI{ri}.CTval, refROI{ri}.map] = sampleROI(baselineImgData, refROI{ri});
% 	refROInames{ri} = refROI{ri}.name;
% end

% scale the pixel size to the target simulated image matrix
lesionImgData = baselineImgData;

% TO DO - do we want to indicate in the header information that this has a
% synthetic lesion?????
% lesionImgData.SeriesDescription = [lesionImgData.SeriesDescription ' - with lesion'];

nLesions = length(lesionData.lesion);
lesions = cell(nLesions,1);
for li=1:nLesions
	lesion = lesionData.lesion{li};
	lesion.map = makeMap(lesionImgData.hdr, lesion, li, lesionData);
	lesion.baselineBackgroundCTintesity = sampleROI(baselineImgData, lesion);
	if ~isfield(lesion,'CTadditionMode')
		lesion.CTadditionMode = 'Final (Homogenous)';
	end
	switch lesion.CTadditionMode
		case 'Incremental' % activity in addition to that already present in the patient
			lesionImgData.vol = lesionImgData.vol + lesion.CTval * lesion.map;
		case 'Final (Homogenous)' % activity after lesion sysnthesis
			lesionImgData.vol(lesion.map>0) = lesion.CTval;
		case 'Final (Maintain Texture)'
			map = lesion.map>0;
			lesionImgData.vol(map) = lesionImgData.vol(map) + lesion.CTval - lesion.baselineBackgroundCTintesity;
		otherwise
			error(['Unrecognized lesion additionMode property ' lesion.CTadditionMode]);
	end
	
	% surrounding summary statistics
	if nargin<3 % TO DO: this assumes spheres, will need to accomodate other shapes when we get there.
		surroundingMargin = 20; % mm
	end
	surrounding = lesion;
	surrounding.shape = 'Empty Sphere (homo)';
	surrounding.rad2 = surrounding.rad + surroundingMargin;

	[lesion.baselineSurroundingCTval, ~, voxelVals] = sampleROI(baselineImgData, surrounding);
	lesion.baselineSurroundingCTnoise = std(single(voxelVals));
	lesion.baselineSurroundingCTmin = min(voxelVals);
	lesion.baselineSurroundingCTmax = max(voxelVals);
	
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
            ROI.rad,...
            1,vars);
        
	otherwise
		disp(['Unrecognized ROI shape ' ROI.shape])
end
end


function [intensity, map, voxelValues] = sampleROI(imgData, ROI)
map = makeMap(imgData.hdr, ROI, 1, 1);
voxelValues = imgData.vol(map>0);
intensity = mean(voxelValues);
end