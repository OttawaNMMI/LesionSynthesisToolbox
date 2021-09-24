function runImageReconServer 

disp('Started Sucess')
datadir = 'E:\LSP Database\Clean Liver Recons\reconQ'; 
folders = listfolders(datadir); 

j = 1; 

rm = 0; 

for i = 1:length(folders)
    if strcmp(folders{i},'completed')
        rm = i;
    else
        temp = load([datadir,filesep,folders{i}, filesep folders{i} '_reconParams.mat']);
        name{j} = temp.info.reconName;
        [~,f,~] = fileparts(temp.info.patdatadir);
        tar{j} = f;
        p{j} = [temp.info.saveDir filesep temp.info.reconName];
        j = j+1;
    end
end

if rm > 0
    folders(rm) = [];
end
                
for i = 1:length(folders)
    
    load([datadir,filesep,folders{i}, filesep folders{i} '_reconParams.mat']);
    	
	basedir =[info.saveDir filesep 'reconQ' filesep info.reconName]; 
	reconDir = info.patdatadir; 
	reconName = info.reconName; 
		
	% Create Dir for BASELINE PET TOF Recon
	mkdir([basedir filesep 'raw']);
	mkdir([basedir filesep 'CTAC']);
	
	% Copy the necessary files to Baseline PET dirs
	copyfile([info.patdatadir filesep 'raw'],[basedir filesep 'raw'])
	copyfile([info.patdatadir filesep 'CTAC'],[basedir filesep 'CTAC'])
	copyfile([info.patdatadir filesep 'norm3d'],[basedir])
	copyfile([info.patdatadir filesep 'geo3d'],[basedir])
	
	cd(basedir) 
	
	reconParams = LesionInsertion_GEPETreconParams; % gen Default LI Params
	reconParams.genCorrectionsFlag = 1; %Turn Corrections on
	
	reconParams.dicomImageSeriesDesc = [info.reconParams.SimName '_BaselineRecon']; 
    reconParams.nx = info.reconParams.nXdim; 
    reconParams.ny = info.reconParams.nYdim; 
	
    reconParams.nz = 47; % PER BED POS
    
	reconParams.algorithm = info.reconParams.Algorithm; 
    reconParams.numSubsets =  info.reconParams.Subsets; 
    reconParams.numIterations = info.reconParams.Iterations; 
    reconParams.zfilter = info.reconParams.zfilter; 
	reconParams.postFilterFWHM = info.reconParams.FilterFWHM;
    reconParams.beta = info.reconParams.beta;
    
    save([basedir filesep 'ReconParams.mat'],'reconParams')
	
	% Perform a PET recon with Attenuation Correction [GT: Patient without Lesion]
	img = GEPETrecon(reconParams);
	
end

end 
