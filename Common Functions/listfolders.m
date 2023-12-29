% folders = listfolders(datadir) - lists subdirectories in a head
% directory. Ignores directories starting with a '.', such as: ., .., .DS
%
% By Ran Klein 22/2/2005

function folders = listfolders(headDir) 
temp = dir(headDir);
count = 1;

folders = []; 

for i = 1:length(temp)
	if ~startsWith(temp(i).name,'.') % Hidden/Filesystem usually has '.' in name
		folders{count} = temp(i).name;
		count = count+1;
	end
end

end