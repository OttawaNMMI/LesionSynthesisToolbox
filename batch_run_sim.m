function batch_run_sim

datadir = 'M:\Perception Recons\JMI Paper'; 

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


for i = 1:length(dinfo)
	load([datadir filesep dinfo(i).name filesep 'LesionParams_',...
		dinfo(i).name '.mat'])
	runLesionInsertionPlusRecon(info.patdatadir,info.datastoredir,info.reconName)
end

end 