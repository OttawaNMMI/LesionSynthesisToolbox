% makefIR3DmatFile - create a FlowQuant standard mat file 
% fname = makefIR3DmatFile(fpath)

% By Ran Klein, The Ottawa Hospital, 2022

function fname = makefIR3DmatFile(fpath, fname)

if exist(fpath,'dir')==7
	load([fpath filesep 'ReconParams.mat'],'reconParams');
	dicomDir = [fpath filesep reconParams.dicomImageSeriesDesc];
else
	load(fpath, 'info');
	fpath = fileparts(fpath);
	dicomDir = [fpath filesep info.reconParams.SimName];
end
% TO DO: should be able to do this without GE generating a DICOM series
infodcm = dicominfo([dicomDir filesep '_bin1_sl1.sdcopen']);
vol = ptbReadSaveFile([fpath filesep 'ir3d.sav']);
hdr = hdrInitDcm(infodcm);
if nargin<2
	fname = [fpath filesep 'fIR3D.mat'];
end
save(fname,  'vol', 'hdr', 'infodcm');
