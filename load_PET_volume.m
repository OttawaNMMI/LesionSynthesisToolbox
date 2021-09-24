function [PET,hdr] = load_PET_volume(datadir) 

f = listfiles('*',datadir); 
numf = length(f); 

for i = 1:numf
	img = dicomread([datadir filesep '_bin1_sl' num2str(i) '.sdcopen']); 
	PET(:,:,i) = img;
	disp(['Read: ' num2str(i) '/' num2str(numf) ' (' num2str(100*(i/numf)),...
		'%)'])
end 

hdr = dicominfo([datadir filesep '_bin1_sl' num2str(i) '.sdcopen']); 


end 