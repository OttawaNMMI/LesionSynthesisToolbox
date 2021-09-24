function folders = listfolders(fpath)

% Cycle through all files/folders to remove
% (1) - All hidden folders (e.g.'.' or '.DS_STORE')
% (2) - All files 
temp = dir(fpath);

folders = [];
count = 1;

for i = 1:length(temp)
    if temp(i).isdir
        if isempty(strfind('.',temp(i).name))
            if isempty(strfind('..',temp(i).name))
                folders{count} = temp(i).name;
                count = count + 1;
            end
        end
    end
end
end