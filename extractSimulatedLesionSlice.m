%--------------------------------------------------------------------------
%
%							THE OTTAWA HOSPITAL
%						Division of Nuclear Medicine
%
%--------------------------------------------------------------------------
%
% extractSimulatedLesionSlice m-file 	
%
% extractSimulatedLesionSlice extracts the single ceter most transaxial(TA)
% slice from the reconstructed PET volume. Uses the lesion definition map
% from the LesionParams_ANON_ _ _ _ _ _ _ _ _.mat file. Will account for
% single bed position recon if the lesion map was defined using a WB PET.
%
% The center most TA slice is determined using MATLAB reconprop3 to
% determine the center of mass (centroid) algorithm.
%
% Usage:		[centerMostTAslice] = extractSimulatedLesionSlice(fReconImg)
%  
%				fReconImg	- [string] file path where ir3d.sav from recon
%							  is saved
% Output [2]: 
%				[1] centerMostTAslice - [2D Matrix] center most TA slice
%				[2] CMTAS_lmap - [2D Matrix] center most TA slice of 
%								 lesion map 
%
% Developer		: HJUMA (hjuma@toh.ca)
% Date Created	: Aug 1 2019
% Last Edited	: Aug 7 2019
% Edit Notes    : Updated help (HJUMA)
% Also See		: batchExtractLesionSlices 
% 
% Notes			: Originally implemented as extract_slice, updated to 
%				  handle errors,single bed position recons, and better 
%				  documented for others. 
 

function [centerMostTAslice,CMTAS_lmap,cROI] = extractSimulatedLesionSlice(fReconImg) 
% extract directory of the path 
[p,~,~] = fileparts(fReconImg); 
% extrac the reconName (naming convention) 
[~,f,~] = fileparts(p); 
% read in reconImg 
if contains(fReconImg,'.sav')
	reconImg = readSavefile(fReconImg);
elseif contains(fReconImg,'.mat')
	load(fReconImg)
	reconImg = img; 
	clear img
end
% derive lesion params filename 
fLesionParams = [p filesep 'LesionParams_' f '.mat']; 

% read lesion params files if present || exit script
if exist(fLesionParams) 
	load(fLesionParams)
else
	warning(['Could not find params file at location: ',...
		fLesionParams]) 
	return
end

% extract lesion definition map
try 
	map = lesion{1}.map;
catch  
	warning('Error reading lesion params map') 
	return
end 


% Confirm MAP is a binary integer MAP
	map(map>0) = 1; 
	% Fill any holes 
	map = imfill(map,'holes'); 
	% Determine the center of the binary map 
	cROI = regionprops3(map,'Centroid'); 
	% round to the nearest full pixel 
	cROI = round(table2array(cROI)); 

% determine if this was a single bed pos recon
if size(reconImg,3) == size(lesion{1}.map,3) 
	disp(['No problem']) 
	
	lesionMap = map; 
	
	
else % SINGLE BED POS RECON
	disp('Determine bed position for extraction') 
	
	% get the map describing the bed position layout 
	% determine the bed position of the TA slice
	range = DetBedPos(BedPosMap,cROI(3)); 
	
	if range(1) == range(2) 
		% grab the slices corresponding to the bed postion
		lesionMap = map(:,:,36*(range(1)-1)+1:47+36*(range(1)-1));
		disp(['Lesion located in bed pos: ' num2str(range(1))])
	else
		warning('Lesion is inbetween multiple bed positions') 
		return
	end 
	
end

% Determine the center of the single bed position lesion binary map 
	cROI = regionprops3(lesionMap,'Centroid'); 
	% round to the nearest full pixel 
	cROI = round(table2array(cROI)); 
	% grab the center most slice from the reconImg
	centerMostTAslice = reconImg(:,:,cROI(3)); 
	CMTAS_lmap = lesionMap(:,:,cROI(3)); 

end 