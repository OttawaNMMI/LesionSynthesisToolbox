% getBedRangeData - resolves the bed positions that need to be processed
% for a lesion simulation.
%
% Usage:
% ======
% [bedRange, numBeds, slicesPerBed, slicesOverlap] = getBedRangeData(lesionImg, slicesPerBed, slicesOverlap)
%
% Input parameters:
% -----------------
% lesionImg - The image of the lesion. Bed positions corresponding to
% non-zero transaxial slices will be returned.
% slicesPerBed - How many slices overlap a single bed position.
% slicesOverlap - How many slices overlap between bed positions.
%
% Output variables:
% -----------------
% bedRange - An array of the bed positions that overlap the lesions.
% numBeds - The total number of bed for the entire image length.
% slicesPerBed - How many slices overlap a single bed position.
% slicesOverlap - How many slices overlap between bed positions.
% Next Step: LesionInsertion_TOFV4
%
% Note: Specific to Discovery 690 and 710 systems.
%
% Author: Ran Klein, PhD, The Ottawa Hospital
% Created: 2020
% Last Modified: 2020-03-19

% TO DO - find a way to resolve slicesPerBed and slicesOverlap from image
% reconstruction data.

function [bedRange, numBeds, slicesPerBed, slicesOverlap] = getBedRangeData(lesionImg, slicesPerBed, slicesOverlap)

if nargin<2
	slicesPerBed = 47;
end
if nargin<3
	slicesOverlap = 11;
end

nSlices = size(lesionImg,3);

numBeds = (nSlices-slicesOverlap) / (slicesPerBed-slicesOverlap);

if mod(numBeds,1) ~= 0
	error('Number of beds is not an integer value. Number of slices do not match scan configuration');
end

a = any(reshape(lesionImg,[],nSlices),1);
bedStart = min(numBeds, floor( ((1:nSlices) -1) / (slicesPerBed-slicesOverlap)) + 1);
bedEnd = max(1,floor( ( (1:nSlices) - slicesOverlap - 1 ) / (slicesPerBed-slicesOverlap))+1);
 
bedRange = min(bedEnd(a)):max(bedStart(a));
% bedRange = union(bedStart(a), bedEnd(a));

%% For debugging purposes
if 0
	figure
	plot(1:nSlices, [bedStart; bedEnd])
	hold on
	plot(1:nSlices, a);
end