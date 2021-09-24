function batchFilterReconData(datadir,fParams)

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
	fSearch = [datadir filesep flders{i} filesep 'ntIR3D.mat']; 
	if isempty(strfind(fSearch,'Broken'))
		if exist(fSearch)
			% Convert to SUV and save
			%img = readSavefile(fSearch); 
			load([fSearch]); img = recon;
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
			
			reconParams.postFilterFWHM = fParams.Filter_FWHM;        % FWHM for gaussian post filter, Units: mm
			reconParams.zfilter = fParams.zFilter;               % Center weighted for 3-point center weighted averager.
			
            
			img = petrecon_postfilter(img, reconParams);
            if flag 
                [p f e] = fileparts(fSearch); 
            end    
            
            if exist(p)
                save([p filesep 'fntIR3D.mat'],'img','reconParams');
            else
                save([datadir filesep flders{i} filesep 'fntIR3D.mat'],'img','reconParams');
            end
            
			disp(['Processed:' fSearch])
		end
	end
end 
end 