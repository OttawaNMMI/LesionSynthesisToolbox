% MakeSphere    Generate a 3D spherical volume in a 3D matrix. This
%               function makes use of a hdr structure that contains the 
%               voxel dimensions for the image space in which the sphere
%               will be generated. Please see the example usage. 
%
% Usage:        [img] = MakeSphere(hdr,ROI_x,ROI_y,ROI_z,ROI_r)
%
% Example Usage: 
% hdr.pix_mm_xy = 700/128; 
% hdr.pix_mm_z = 3.27; 
% hdr.xdim = 128; 
% hdr.ydim = 128; 
% hdr.nplanes = 47; 
% 
% 
% vol = zeros(128,128,47); 
% 
% ROI_x = 64; % Units are in pixels
% ROI_y = 64; % Units are in pixels
% ROI_z = 20; % Units are in pixels
% ROI_r = 20; % Units are in mm
% 
% vol = MakeSphere(hdr,ROI_x,ROI_y,ROI_z,ROI_r);
% 
% View4D(vol)
%
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2017
% Last Modified: April 18 2019 (Doc.)

function img = MakeSphere(hdr, ROI_x, ROI_y, ROI_z, ROI_r, int)

img = zeros(hdr.xdim, hdr.ydim, hdr.nplanes);
ROI_x = (ROI_x-0.5)*hdr.pix_mm_xy; 
ROI_y = (ROI_y-0.5)*hdr.pix_mm_xy; 
ROI_z = (ROI_z-0.5)*hdr.pix_mm_z; 

[x, y] = meshgrid(linspace(0.5*hdr.pix_mm_xy, (hdr.xdim-0.5)*hdr.pix_mm_xy, hdr.xdim),...
	              linspace(0.5*hdr.pix_mm_xy, (hdr.ydim-0.5)*hdr.pix_mm_xy, hdr.ydim));

for zi = 1:hdr.nplanes
	radius = sqrt (((x-ROI_x).^2) + ((y-ROI_y).^2) + ((((zi-0.5)*hdr.pix_mm_z)-ROI_z).^2));
	img(:,:,zi) = radius <= ROI_r;
end

img = img.*int; 
end 





