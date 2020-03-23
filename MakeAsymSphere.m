function [mask] = MakeAsymSphere(img, hdr, ROI_x,ROI_y,ROI_z,ROI_r, int)

ROI_x = ROI_x*hdr.pix_mm_xy; 
ROI_y = ROI_y*hdr.pix_mm_xy; 
ROI_z = ROI_z*hdr.pix_mm_z; 

[y,x,z] = meshgrid(linspace(hdr.pix_mm_xy,hdr.xdim*hdr.pix_mm_xy,hdr.xdim),...
                    linspace(hdr.pix_mm_xy,hdr.ydim*hdr.pix_mm_xy,hdr.ydim),...
                    linspace(hdr.pix_mm_z,hdr.nplanes*hdr.pix_mm_z,hdr.nplanes));

                
mask = (( (x-ROI_x).^2 + (y-ROI_y).^2 + (z-ROI_z).^2).*(1+0.2*randn(size(x))) ) < ROI_r^2;
mask( ((x-ROI_x).^2 + (y-ROI_y).^2 + (z-ROI_z).^2) < (ROI_r/2)^2) = true; % make sure core is filled
mask = imfill(mask,'holes'); % fill in some holes
mask = mask & imfill(~mask, round([ROI_x/hdr.pix_mm_xy ROI_y/hdr.pix_mm_xy ROI_z/hdr.pix_mm_z])); % get rid of discovvencted pixels
mask = mask*int;
end 

