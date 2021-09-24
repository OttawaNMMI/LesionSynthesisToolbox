function runReconServer2 

disp('Started Sucess')
datadir = 'M:\Discovery_DR\Discovery_DR\Simulations'; 
folders = listfolders(datadir); 

j = 1; 

for i = 1:length(folders)
    if strcmp(folders{i},'completed')
        rm = i;
    else
        temp = load([datadir,filesep,folders{i}, filesep 'LesionParams_' folders{i}]);
        name{j} = temp.info.reconName;
        [~,f,~] = fileparts(temp.info.patdatadir);
        tar{j} = f;
        nObject{j} = length(temp.lesion);
        p{j} = [temp.info.savedir filesep temp.info.reconName];
        j = j+1;
    end
end

if rm > 0
    folders(rm) = [];
end
                
for i = 1:length(folders)
    
    load([datadir,filesep,folders{i}, filesep 'LesionParams_' folders{i}]);
    % Run Lesion Synthesis
    %runLesionInsertionPlusRecon_WebApp(info.patdatadir,info.savedir,info.reconName)
    img = GEPETrecon(reconParams);
end

end 
