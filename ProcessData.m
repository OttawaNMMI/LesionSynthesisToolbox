function ProcessData

datadir = 'M:\Perception Recons\Liver Lesions Aug 8'; 
datadir = 'M:\Perception Recons\batch_user_define'; 
datadir = 'C:\Users\hjuma\OneDrive - The Ottawa Hospital\Synthetic Lesions - July';
datadir = 'C:\Users\hjuma\OneDrive - The Ottawa Hospital\New Folder 12'; 
datadir = 'C:\temp\Discovery_DR\Clean Liver Recons'; 
datadir = 'C:\Users\hjuma\OneDrive - The Ottawa Hospital\Papers in Progress\MIPs Special Edition 2019\Data\OCOG Simulation 2\Validate_OCOG_NEMA_192_TOF\CTreconWithLesion'; 

temp = dir(datadir); 
count = 1; 
for i = 1:length(temp)
	if strfind(temp(i).name,'.') % Hidden/Filesystem usually has '.' in name 	
		warning(['Found non-patient folder at path: ' datadir filesep,...
			temp(i).name])
	else
		flders{count} = temp(i).name; 
		count = count+1; 
	end
end 

for i = 1:length(flders)
	fSearch = [datadir filesep flders{i} filesep 'ir3d.sav'];
	if isempty(strfind(fSearch,'Broken'))
		if exist(fSearch)
			% Convert to SUV and save
			img = readSavefile(fSearch); 
			
            try 
                load([datadir filesep flders{i} filesep 'Params.mat'])
                flag = 0; 
            catch ME 
                disp('USING DEFAULT PARAMS')
                GEPETreconParams; 
                reconParams.nx = size(img,1); 
                reconParams.ny = size(img,2);
                flag = 1; 
            end 
			
			[p f e] = fileparts(reconParams.dir(1:end-1)); 
			
			reconParams.postFilterFWHM = 6.4;         % FWHM for gaussian post filter, Units: mm
			reconParams.zfilter = [4];                % Center weighted for 3-point center weighted averager.
			
            
			img = petrecon_postfilter(img, reconParams);
            if flag 
                [p f e] = fileparts(fSearch); 
            end    
            
            if exist(p)
                save([p filesep 'fIR3D.mat'],'img','reconParams');
            else
                save([datadir filesep flders{i} filesep 'fIR3D.mat'],'img','reconParams');
            end
            
			disp(['Processed:' fSearch])
		end
	end
end 

% Apply Filter 

% Convert to SUV 

% Extract Single TAS 

end 