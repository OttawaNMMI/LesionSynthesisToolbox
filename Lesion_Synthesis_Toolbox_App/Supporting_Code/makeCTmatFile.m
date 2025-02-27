% makeCTmatFile - create a FlowQuant standard mat file of an image in a
% DICOM directory, fpath.
%
% Usage:
% ======
% fname = makeCTmatFile(fpath, fname) - specifies the DICOM directory,
% fpath and destinames file name, fname;
%
% fname = makeCTmatFile(fpath) - uses a default destiname file name, fname
% which is the same as fpath directory.
%
% See also: LesionSynthesisToolbox, runImageRecon_WebApp

% By Ran Klein, The Ottawa Hospital, 2022
% 2023-02-09 - Comments added

function fname = makeCTmatFile(fpath, fname)

[vol, spatial] = dicomreadVolume(fpath);
vol = squeeze(vol);
files = listfiles('*.1',fpath);
if isempty(files) % UBC provided filenames had .img extension appended.
	files = listfiles('*.1.img',fpath);
end
infodcm = dicominfo([fpath filesep files{1}]);
hdr = hdrInitDcm(infodcm);
hdr.pix_mm_z = diff(spatial.PatientPositions(1:2,3)); % I think this is a GE bug that flips SliceThickness and SpacingBetweenSLices
hdr.nplanes = size(vol,3);
vol = permute(vol,[2 1 3]);
vol = flip(vol,3);
vol = vol*infodcm.RescaleSlope + infodcm.RescaleIntercept;
if nargin<2
	[f, p, ~] = fileparts(fpath);
	fname = [f filesep p '.mat'];
end
save(fname,  'vol', 'hdr', 'infodcm');
