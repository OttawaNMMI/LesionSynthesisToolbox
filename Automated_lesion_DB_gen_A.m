% Direcotry with target patients 
datadir = 'C:\temp\Discovery_DR\Clean Liver Recons'; 
info.datastoredir =  'M:\Perception Recons\Testing Automated Server'; 

% Auto Lesion Gen Params
d = [2 4 6]; %[8,10,12.5,15,17.5,20] 2,4,6]; %,
c = 0.25:0.25:4.5;

d = 8; 
c = 4.5; 

% Get info of folders in datadir path
temp = dir(datadir); 
count = 1; 
for i = 1:length(temp)
	if strfind(temp(i).name,'.') % Hidden/Filesystem usually has '.' in name 	
		warning(['Found non-patient folder at path: ' datadir filesep,...
			temp(i).name])
	else
		dinfo(count).name = temp(i).name; 
		count = count+1; 
	end
end 

for i = 1:length(d) 
	for j = 1:length(c) 
		tar = round(length(dinfo)*rand(1)); 
		
		while tar == 0 
			tar = round(length(dinfo)*rand(1));
		end 
		
		patdir = [datadir filesep dinfo(tar).name]; 
		
		load([patdir filesep 'LesionBoundParams.mat']); 
		
		imgGT = readSavefile([patdir filesep 'ir3d.sav']); 
		
		phantom = zeros([2*size(imgGT,1),2*size(imgGT,2),size(imgGT,3)]);
		
		% Create the HDR struct based on # of data elements
		lesionBound.hdr.pix_mm_xy = 700/(2*size(imgGT,1));
		lesionBound.hdr.pix_mm_z = 3.27;
		lesionBound.hdr.xdim = 2*size(imgGT,1);
		lesionBound.hdr.ydim = 2*size(imgGT,2);
		lesionBound.hdr.nplanes = size(imgGT,3);
		
		ROI_x = lesionBound.x_mm + rand(1)*lesionBound.r_mm; 
		ROI_y = lesionBound.y_mm + rand(1)*lesionBound.r_mm;
		ROI_z = lesionBound.z_mm + rand(1)*lesionBound.r_mm;
		
		[phantom] = MakeSphere(phantom,lesionBound.hdr,ceil(ROI_x/lesionBound.hdr.pix_mm_xy),...
			ceil(ROI_y/lesionBound.hdr.pix_mm_xy),...
			ceil(ROI_z/lesionBound.hdr.pix_mm_z),d(i)/2,1);
		
		phantom  = phantom*c(j); 
		
		phantom = imresize3(phantom,[size(imgGT,1),size(imgGT,2),size(imgGT,3)]); 
		
		lesionCount = 2; % Must be +1 then number of lesions
		
		lesion{lesionCount-1}.map = phantom;
		lesion{lesionCount-1}.uptake = c(j);
		lesion{lesionCount-1}.ROI_x = ROI_x; 
		lesion{lesionCount-1}.ROI_y = ROI_y; 
		lesion{lesionCount-1}.ROI_z = ROI_z;
		lesion{lesionCount-1}.ROI_r = d(i)/2; 
		
		
		info.reconName = ['ANONa_d' num2str(d(i)*100) '_c' num2str(c(j)*100)];

		info.patdatadir = patdir; 
	
		% Make the dir to save the lesion synthesis study files
		mkdir([info.datastoredir],info.reconName)
		
		% Save the lesion binary map and other necessary parameters
		save([info.datastoredir filesep info.reconName filesep 'LesionParams_' info.reconName '.mat'],'lesion','lesionCount','info')
		
		% Run Lesion Synthesis
		runLesionInsertionPlusRecon(info.patdatadir,info.datastoredir,info.reconName)
	end
end 

