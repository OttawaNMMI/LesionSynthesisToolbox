% MakeAsymSphere - make a "noisy" sphere volumetric image. 
%
% Usage:
% img = MakeAsymSphere(hdr, ROI_x,ROI_y,ROI_z,ROI_r, int) - add to
% the 3D volume image with header (hdr) a noisy sphere centered as
% [ROI_x, ROI_y, ROI_z] with average radius ROI_r and intenstensity int.
%
% Note: results in discconnected section, so tried to replace with
% MakeBlobbySphere.m

% By Ran Klein, The Ottawa Hospital, 2023

function img = MakeAsymSphere(hdr, ROI_x,ROI_y,ROI_z,ROI_r, int)

ROI_x = ROI_x*hdr.pix_mm_xy; 
ROI_y = ROI_y*hdr.pix_mm_xy; 
ROI_z = ROI_z*hdr.pix_mm_z; 

[y,x,z] = meshgrid(linspace(hdr.pix_mm_xy,hdr.xdim*hdr.pix_mm_xy,hdr.xdim),...
                    linspace(hdr.pix_mm_xy,hdr.ydim*hdr.pix_mm_xy,hdr.ydim),...
                    linspace(hdr.pix_mm_z,hdr.nplanes*hdr.pix_mm_z,hdr.nplanes));

                
img = (( (x-ROI_x).^2 + (y-ROI_y).^2 + (z-ROI_z).^2).*(1+0.2*randn(size(x))) ) < ROI_r^2;
img( ((x-ROI_x).^2 + (y-ROI_y).^2 + (z-ROI_z).^2) < (ROI_r/2)^2) = true; % make sure core is filled
img = imfill(img,'holes'); % fill in some holes
img = img & imfill(~img, round([ROI_x/hdr.pix_mm_xy ROI_y/hdr.pix_mm_xy ROI_z/hdr.pix_mm_z])); % get rid of discovvencted pixels
img = img*int;
end 

