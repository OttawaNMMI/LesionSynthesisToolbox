function loc = convertImgLocationUnits(hdr, loc, sourceUnits, targetUnits)

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
end

switch targetUnits
	case {'mm','mm from origin'}
		loc(1) = loc(1)*hdr.pix_mm_xy;
		loc(2) = loc(2)*hdr.pix_mm_xy;
		loc(3) = loc(3)*hdr.pix_mm_z;
	case 'mm from center'
		loc(1) = (loc(1)-hdr.xdim/2)*hdr.pix_mm_xy;
		loc(2) = (loc(2)-hdr.ydim/2)*hdr.pix_mm_xy;
		loc(3) = loc(3)*hdr.pix_mm_z;
	case 'pixel'
		% do nothing
     case 'relative fraction'
        loc(1) = loc(1)/hdr.xdim;
        loc(2) = loc(2)/hdr.ydim;
        loc(3) = 1-loc(3)/hdr.nplanes;
end
end