% convertImgLocationUnits - converts the representation of image
% coordinates to a corresponding units

%Usage:
% loc = convertImgLocationUnits(hdr, loc, sourceUnits, targetUnits) where:
% - hdr is the LST image structure (including image header).
% - loc is a triplet of image coordinaes [x,y,z].
% - sourceUnits is a string with the source coordinate units.
% - targetUnits is a string with the target coordinate units.
%
% Supported coordinates are:
% - 'mm' or 'mm from origin' - milimeters from the image origin (top, left,
% front of patient).
% - 'pixel' - pixels from the image origin (top, left, front of patient).
% - 'mm from center' - milimeters from the center of the image (coronal and sagital) and top.
% - 'relative fraction' - fraction of image dimensions relative to origins
% (bottom, left, front of patient).
% - 'relative percentage' - percentage of image dimensions relative to origins
% (top, left, front of patient).

% By Ran Klein, The Ottawa Hospital, 2022

function [loc, units] = convertImgLocationUnits(hdr, loc, sourceUnits, targetUnits)

switch sourceUnits
	case {'mm','mm from origin'}
		loc(1) = loc(1)/hdr.pix_mm_xy;
		loc(2) = loc(2)/hdr.pix_mm_xy;
		loc(3) = loc(3)/hdr.pix_mm_z;
	case 'mm from center'
		loc(1) = loc(1)/hdr.pix_mm_xy + hdr.xdim/2;
		loc(2) = loc(2)/hdr.pix_mm_xy + hdr.ydim/2;
		loc(3) = loc(3)/hdr.pix_mm_z;
	case 'pixel'
		% do nothing
    case 'relative fraction'
        loc(1) = loc(1)*hdr.xdim;
        loc(2) = loc(2)*hdr.ydim;
        loc(3) = (1-loc(3))*hdr.nplanes;
	case 'relative percentage'
        loc(1) = loc(1)*hdr.xdim/100;
        loc(2) = loc(2)*hdr.ydim/100;
        loc(3) = (1-loc(3))*hdr.nplanes/100;
end

switch targetUnits
	case {'mm','mm from origin'}
		loc(1) = loc(1)*hdr.pix_mm_xy;
		loc(2) = loc(2)*hdr.pix_mm_xy;
		loc(3) = loc(3)*hdr.pix_mm_z;
		units = 'mm';
	case 'mm from center'
		loc(1) = (loc(1)-hdr.xdim/2)*hdr.pix_mm_xy;
		loc(2) = (loc(2)-hdr.ydim/2)*hdr.pix_mm_xy;
		loc(3) = loc(3)*hdr.pix_mm_z;
		units = 'mm';
	case 'pixel'
		% do nothing
		units = 'pixels';
     case 'relative fraction'
        loc(1) = loc(1)/hdr.xdim;
        loc(2) = loc(2)/hdr.ydim;
        loc(3) = 1-loc(3)/hdr.nplanes;
		units = '';
	case 'relative percentage'
        loc(1) = loc(1)/hdr.xdim*100;
        loc(2) = loc(2)/hdr.ydim*100;
        loc(3) = 1-loc(3)/hdr.nplanes*100;
		units = '%';
end
end