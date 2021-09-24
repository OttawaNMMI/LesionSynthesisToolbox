function batchRecon2SUVunits(datadir) 

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
	fSearch = [datadir filesep flders{i} filesep 'fntIR3D.mat'];
	if isempty(strfind(fSearch,'Broken'))
		if exist(fSearch)
			% Convert to SUV and save
			[img, hdr, uptakeUnits] = reconImg2SUVimg(fSearch);
			hdr.fIR3D = fSearch;
			save([datadir filesep flders{i} filesep 'ntIR3D_SUV.mat'],'img','hdr');
			disp(['Processed:' fSearch])
		else
			disp(['Could not locate IR3D.sav at:' fSearch])
		end
	else
		disp(['Skipped:' fSearch])
	end
end
end