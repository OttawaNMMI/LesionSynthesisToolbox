function anonGEreconOutput(dirIn, dirOut, hdrOverwrite)

if nargin<1
	dirIn = pwd;
end
if nargin<2
	dirOut = [dirIn filesep 'Anon'];
	mkdir(dirOut);
else 
	mkdir(dirOut); 
end 

nameconv = '_bin1_sl'; 

fext = '.sdcopen'; 

files = listfiles(fext,dirIn); 

for i = 1:length(files)
    
    fdir = [dirIn filesep nameconv num2str(i) fext]; 
    
    if ~exist(fdir,'file')
        disp(['Could not find file at .. ' fdir])
    else 
        img = dicomread(fdir); % Get the image volume double(vol(:,:,i));  %
   
		infodcm = dicominfo(fdir);
		
		infodcm.PatientBirthDate = [infodcm.PatientBirthDate(1:4) '0101'];

		
		if i==1
			if nargin<3
				hdrOverwrite = struct('PatientName','ANON',...
					'PatientID','0000000',...
					'PatientBirthDate',[infodcm.PatientBirthDate(1:4) '0101'],...
					'ReferringPhysicianName','DELETE');
			end
			fnames = fieldnames(hdrOverwrite);
		end
		
		for fi = 1:length(fnames)
			fname = fnames{fi};
			if strcmp(hdrOverwrite.(fname), 'DELETE')
				infodcm = rmfield(infodcm, fname);
			else
				infodcm.(fname) = hdrOverwrite.(fname);
			end
		end
						
        dicomwrite(img, [dirOut filesep nameconv num2str(i) fext] ,infodcm,'CreateMode','Copy')
    end
    
end 


end 