function map = makeMap(hdr, ROI)
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
	otherwise
		disp(['Unrecognized rederence ROI shape ' ROI.shape])
end
end