function [CTAC, hdr] = load_CTAC_volume(datadir) 

f = listfiles('*',datadir); 
numf = length(f); 

for i = 1:numf
	img = dicomread([datadir filesep f{i}]); 
	CTAC(:,:,i) = img;
	disp(['Read: ' num2str(i) '/' num2str(numf) ' (' num2str(100*(i/numf)),...
		'%)'])
end 

hdr = dicominfo([datadir filesep f{i}]); 

end 