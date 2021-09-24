%test lesion intensities
function testLesionIntensities(dir)
if nargin<1
	dir = pwd;
end

disp(['Checking lesion intensities for ' dir]);
cd(dir);

load('reconParams.mat','baselineImgData');

lesionImgData = load('fIR3D.mat');

filename = listfiles('*.mat');
fi = startsWith(filename,'LesionParams');
filename = filename{fi};
lesionDataSimulated = load(filename);

% Resample activities from the baseline image
[lesionImgB, lesionDataB, refDataB] = makeLesionImage(baselineImgData, lesionDataSimulated);

% Resample activities from the lesion image
[lesionImgL, lesionDataL, refDataL] = makeLesionImage(lesionImgData, lesionDataSimulated);


% Compare pre-synthesis and post-synthesis refROI sampled activities
for ri = 1:length(refDataB)
	imageSampledPTInt = mean(lesionImgData.vol(refDataL{ri}.map>0));
	expectedPTInt =refDataB{ri}.PTintensity;
	disp(['Ref ROI ' refDataB{ri}.name ' ' num2str(imageSampledPTInt) ' vs ' num2str(expectedPTInt) ' = ' num2str(100*imageSampledPTInt/expectedPTInt-100) '% error'])
end

% Compared intended lesion activities with image sampled activities
for li = 1:length(lesionDataB)
	imageSampledPTInt = mean(lesionImgData.vol(lesionDataL{li}.map>0));
% 	can also be replaced with the following if PVE included in map
% 	imageSampledPTInt = sum(imgData.vol(:) .* lesionData{li}.map(:)) / sum(lesionData{li}.map(:));
	expectedPTInt = lesionDataB{li}.PTintensity;
	error = num2str(100*imageSampledPTInt/expectedPTInt-100);
	disp(['Lesion ROI ' lesionDataB{li}.name ', mode (' lesionDataB{li}.mode ' ,' num2str(lesionDataB{li}.PTval) ') : ' num2str(imageSampledPTInt) ' vs ' num2str(expectedPTInt) ' = ' error '% error'])
end
