clfunction checkReconWithSim

datadir = 'M:\Perception Recons\user_define_eTAS'; 
saveDir = 'M:\Perception Recons\Verified_Aug_21_eTAS'; 
files = listfiles('.mat',datadir); 

figure; 
for i = 1:length(files)
	disp(num2str(i))
	
	subplot(1,2,1)
	load([datadir filesep files{i}]) 
	imagesc(img)
	set(gca,'clim',[0 4]); 
	title(files{i})
	axis('image')
	
	subplot(1,2,2) 
	imagesc(lmap)
	axis('image')
	
	
	ans = questdlg('Keep Scan','Yes','No'); 
	
	switch ans
		case 'Yes'
			disp(['Keep: '  files{i}])
			copyfile([datadir filesep files{i}],[saveDir filesep files{i}])
		case 'No'
			disp(['Remove: ' files{i}])
	end
	
	clf
	img = []; 
end 




end 