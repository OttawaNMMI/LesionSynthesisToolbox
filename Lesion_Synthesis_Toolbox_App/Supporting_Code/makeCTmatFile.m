% makeCTmatFile - create a FlowQuant standard mat file 
% fname = makeCTmatFile(fpath)
function fname = makeCTmatFile(fpath, fname)

[vol, spatial] = dicomreadVolume(fpath);
vol = squeeze(vol);
files = listfiles('*.1',fpath);
infodcm = dicominfo([fpath filesep files{1}]);
hdr = hdrInitDcm(infodcm);
hdr.pix_mm_z = diff(spatial.PatientPositions(1:2,3)); % I think this is a GE bag that flips SliceThickness and SpacingBetweenSLices
hdr.nplanes = size(vol,3);
vol = permute(vol,[2 1 3]);
vol = flip(vol,3);
vol = vol*infodcm.RescaleSlope + infodcm.RescaleIntercept;
if nargin<2
	[f, p, ~] = fileparts(fpath);
	fname = [f filesep p '.mat'];
end
save(fname,  'vol', 'hdr', 'infodcm');
