% Purpose of this script is to batch process multiple target image files 
% to specify target lesion boundaries (for further processing i.e. random 
% location generation)
%
% Developer: Hanif Gabrani-Juma, MASc (2019)
% Date: July 26 2019
% Last Modified: July 26 2019 - HGJ 
% Notes: 

% Direcotry with target patients 
datadir = 'C:\temp\Discovery_DR\Clean Liver Recons'; 

% Get info of folders in datadir path
info = dir(datadir); 

% Cycle through each of the folders found 
for i = 1:length(info)
	if strfind(info(i).name,'.') % Hidden/Filesystem usually has '.' in name 	
		warning(['Found non-patient folder at path: ' datadir filesep,...
			info(i).name])
	else
		% We have target patient filepath
		% Determine path of target image
		imgPath = [datadir filesep info(i).name filesep 'ir3d.sav']; 
		% Determine if file exist at target image path 
		if ~exist(imgPath) 
			% File does not exist at path 
			warning(['Could not find target image at path: ' imgPath])
			continue
		else 
			% Read target image data from file path
			img = readSavefile(imgPath);
			
			% Create hdr struct (info) about image dimensions 
			% Create the HDR struct based on # of data elements
			hdr.pix_mm_xy = 700/size(img,1); % 700mm FOV 
			hdr.pix_mm_z = 3.27; % Not pretty but OK for now 
			hdr.xdim = size(img,1);
			hdr.ydim = size(img,2);
			hdr.nplanes = size(img,3);
			
			% add target patient path into hdr struct 
			hdr.patdir = [datadir filesep info(i).name];
			
			% Load volume in View4D to get sphereical target lesion 
			% boundaries in mm istead of voxel number 
			% Type 's' to start sphere at crosshair point 
			% use '<' & '>' to change sphere size
			% hit close when sphere boundaries is good
			[frames,ROI_x,ROI_y,ROI_z,ROI_r] = View4D(img,[],...
				'PixelDimensions',[hdr.pix_mm_xy*[1 1] hdr.pix_mm_z],...
				'WaitForClose',true, 'FigureName', '4dview');
			
			% Create lesion boundaries info struct
			lesionBound.x_mm = ROI_x; 
			lesionBound.y_mm = ROI_y; 
			lesionBound.z_mm = ROI_z; 
			lesionBound.r_mm = ROI_r;
			lesionBound.hdr = hdr; 
			
			% Write the lesion boundaries info struct to file in the 
			% target patient directory
			save([datadir filesep info(i).name filesep,...
				'LesionBoundParams.mat'],'lesionBound') 			
		end 
	end 
end 