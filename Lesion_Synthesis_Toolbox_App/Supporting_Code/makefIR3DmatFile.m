% makefIR3DmatFile - create a FlowQuant standard mat file 
% fname = makefIR3DmatFile(fpath)
function fname = makefIR3DmatFile(fpath, fname)

load([fpath filesep 'ReconParams.mat'],'reconParams');
% TO DO: should be able to do this without GE generating a DICOM series
infodcm = dicominfo([fpath filesep reconParams.dicomImageSeriesDesc filesep '_bin1_sl1.sdcopen']);
vol = readSavefile([fpath filesep 'ir3d.sav']);
hdr = hdrInitDcm(infodcm);
if nargin<2
	fname = [fpath filesep 'fIR3D.mat'];
end
save(fname,  'vol', 'hdr', 'infodcm');
