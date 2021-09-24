%MakeLesionInsertionStudy(patdir,datastoredir, reconName)

function runSimulations_02

datadir = 'C:\temp\Discovery_DR\Simulations'; 

names = {'ANON_d15_c400',...
'ANON_d15_c350',...
'ANON_d15_c200',...
'ANON_d15_c050'}; 

for i = 1:length(names) 
	load([datadir filesep names{i} filesep 'LesionParams_' names{i} '.mat']); 
	runLesionInsertionPlusRecon(info.patdatadir,info.datastoredir,info.reconName)
end

end 
