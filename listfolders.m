function [folders] = listfolders(datadir) 
temp = dir(datadir);
count = 1;

folders = []; 

for i = 1:length(temp)
	if ~startsWith(temp(i).name,'.') % Hidden/Filesystem usually has '.' in name
		folders{count} = temp(i).name;
		count = count+1;
	end
end

end