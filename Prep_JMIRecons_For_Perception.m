function Prep_Recons_For_Perception 

% Define Runtime Parameters 
SS = 3; % Start Step
reconDataDir = 'M:\Perception Recons\JMI Paper'; 
eSliceDir = 'M:\Perception Recons\JMI Paper eTASlice'; 

% STEP 1 - Apply Filter on Recon Images
% Simulations have been recon w/o filter to facilitate post-recon options 
if SS <= 1
	fParams.Filter_FWHM = 6.4;
	fParams.zFilter = 4;
	
	batchFilterReconData(reconDataDir,fParams)
else 
	disp('SKIPPED STEP: No Filtering Applied')
end

% STEP 2 - Convert Recon Img (Bq/cc) to SUV 
if SS <= 2 
	batchRecon2SUVunits(reconDataDir)
else 
	disp('SKIPPED STEP: No SUV Conversion')
end 

% STEP 3 - Extract TransAxial Slice (Center of Lesion) 
if SS <=3 
	batchExtractLesionSlices(reconDataDir,eSliceDir)
end 
end 