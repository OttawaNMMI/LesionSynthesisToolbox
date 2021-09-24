function remove_simfiles

datadir = 'M:\Perception Recons\Liver Lesions\'; 

temp = dir(datadir); 
count = 1; 

for i = 1:length(temp)
	if strfind(temp(i).name,'.') 
	
	else 
		flders{count} = temp(i).name; 
		count = count +1; 
	end 
end 

for j = 1:length(flders)
	if exist([datadir  flders{j} filesep 'LesionProjs_frame1'])
		disp('REMOVING:')
		disp([datadir  flders{j} filesep 'LesionProjs_frame1'])
		rmdir([datadir  flders{j} filesep 'LesionProjs_frame1'],'s')
	end
end


end 