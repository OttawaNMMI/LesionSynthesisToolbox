datadir = 'C:\Users\hjuma\OneDrive - The Ottawa Hospital\Aug 8 Lesion Liver TAS'; 
saveDir = 'C:\Users\hjuma\OneDrive - The Ottawa Hospital\Perception TAS V2\Aug 8 2'; 
files = listfiles('.mat',datadir); 

figure; 
for i = 1:length(files)
	disp(num2str(i))
	load([datadir filesep files{i}]) 
	imagesc(img)
	set(gca,'clim',[0 5]); 
	title(files{i})
	
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