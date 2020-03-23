
%% Add path to a directory where m-files are parked
addpath('/projects/petsims/users/Sangtae/Maya/LaPitieCode');


%% Base directory
baseDir = '/projects/petsims/users/Sangtae/Maya/work/base_filt4';
registeredCTpifaDir = '/projects/petsims/users/Sangtae/Maya/CTpifa'; % where registered CT based rdf.1.1.pifa_comp and rdf.1.1.pifa_ivv are
MRACpifaDir = '/projects/petsims/users/Sangtae/Maya/work/base_filt4/RefRecon-1'; % where MRAC based rdf.1.1.pifa_comp and rdf.1.1.pifa_ivv are
PETrawDir = '/projects/petsims/users/Sangtae/Maya/work/base_filt4/RefRecon-1/raw'; % where PET raw data (DICOM) are


%% Recon with attenuation correction (AC) based on registerd CT --> lesion-absent Ground truth image
CTreconDir = [baseDir '/CTrecon']; % working directory for recon with AC based on registered CT
mkdir(CTreconDir);
cd(CTreconDir);
system(sprintf('cp -r %s .',PETrawDir)); % Copy PET raw data
system(sprintf('cp %s/rdf.1.1.pifa* .',registeredCTpifaDir)); % Copy rdf.1.1.pifa_comp and rdf.1.1.pifa_ivv from registered CT based AC

reconParams = DBmake_GEPETreconParams('EV')  ; % EV -> Everest -> PETMR
reconParams.algorithm          = 'TOFOSEM'   ; 
reconParams.MRAC.AnatomyID     = ['LH']      ; 
reconParams.MRAC.pseudoCTflag  = 0           ; % Read pseudoCT from pseudoCT directory!
reconParams.MRAC.HNSpecial     = 0           ; % Do not run dedicated H&N MRAC  
reconParams.postFilterFWHM    = 3           ; % [MK] Transxial post-filter FWHM specification
reconParams.zfilter           = 6           ; % [MK] Axial post-filter strength    (4 = standard; 0 = no filter; 2 = heavy; 6 = light)
% La pitie recon params
reconParams.numIterations     = 4;
reconParams.numSubset         = 0; % 28 subsets
reconParams.nx                = 256;
reconParams.ny                = 256;
reconParams.detectorResponseFlag = 2; %PSF on    
reconParams.MRAC.TruncComplete = 0           ; 

% Save the recon parameters for future reference
save Params reconParams;  

% Perform PET reconstruction
img = GEPETrecon(reconParams);


%% Lesion image (in Bq/ml) which will be added to the lesion-absent ground truth image
cd(CTreconDir);
img = readSavefile('ir3d.sav'); % Lesion-absent ground truth image

% Generate your own lesion image (which will be added to the lesion-absent
% ground truth image).
% The following is an "example" of spherical lesion (diameter 10 mm) centered
% on (130,93,45) with the local contrast of 3.
% You can put multiple lesions in one lesion image if they are sufficiently
% separated. Or you can repeat the whole process with a new lesion image.
% You can also create a lesion image such that the lesion has a pre-determined SUV 
[nx,ny,nz] = size(img);
cx = 130; cy = 93; cz = 45; % lesion center coordinates
sx = 700/nx; sz = 3.2700; %2.78; % voxel size in mm %Previously 600 ? HGJ
lesionDiameter = 10; % in mm
rx = (lesionDiameter/2)/sx; rz = (lesionDiameter/2)/sz; % radius in voxel
lesionProfile = ellipsoid(nx,ny,nz,cx,cy,cz,rx,rx,rz);
lesionBinaryMask = lesionProfile>0; % ROI for quantitation. Alternatively, you lesionBinaryMask = lesionProfile>0.5
localBackgroundActivity = mean(img(lesionBinaryMask));
localContrast = 3;
lesionImg = lesionProfile*localContrast*localBackgroundActivity; % lesion image (in Bq/ml) to be added
trueImg = lesionImg + img; % Ground truth image 


%% Lesion insertion: create (Poisson-noisy) lesion sinogram in /LesionProjs_frame1
% The same recon params as used in recon
reconParams = DBmake_GEPETreconParams('EV','TOFOSEMS')  ; % "TOFOSEMS" incorporates PSF
reconParams.algorithm          = 'TOFOSEM'   ; 
reconParams.numSubset         = 0; % 28 subsets
reconParams.nx                = 256;
reconParams.ny                = 256;

% Lesion insertion flag
reconParams.lesionInsertionTOFFlag = 1; 

% Generate Poisson-noisy lesion sinogram in /LesionProjs_frame1
lesionInsertion(lesionImg,reconParams);


%% Recon with registered CT AC using inserted lesion data
CTreconWithLesionDir = [baseDir '/CTreconWithLesion']; % working directory for recon
mkdir(CTreconWithLesionDir);
cd(CTreconWithLesionDir);
system(sprintf('cp -r %s .',PETrawDir)); % Copy PET raw data
system(sprintf('cp %s/rdf.1.1.pifa* .',registeredCTpifaDir)); % Copy rdf.1.1.pifa_comp and rdf.1.1.pifa_ivv from registered CT based AC
system(sprintf('ln -s %s/LesionProjs_frame1 LesionProjs_frame1',CTreconDir)); % Link the inserted lesion sinogram data

reconParams = DBmake_GEPETreconParams('EV')  ; % EV -> Everest -> PETMR
reconParams.algorithm          = 'TOFOSEM'   ; 
reconParams.MRAC.AnatomyID     = ['LH']      ; 
reconParams.MRAC.pseudoCTflag  = 0           ; % Read pseudoCT from pseudoCT directory!
reconParams.MRAC.HNSpecial     = 0           ; % Do not run dedicated H&N MRAC  
reconParams.postFilterFWHM    = 3           ; % [MK] Transxial post-filter FWHM specification
reconParams.zfilter           = 6           ; % [MK] Axial post-filter strength    (4 = standard; 0 = no filter; 2 = heavy; 6 = light)
% La pitie recon params
reconParams.numIterations     = 4;
reconParams.numSubset         = 0; % 28 subsets
reconParams.nx                = 256;
reconParams.ny                = 256;
reconParams.detectorResponseFlag = 2; %PSF on    
reconParams.MRAC.TruncComplete = 0           ; 

reconParams.lesionInsertionTOFFlag = 1; % Lesion insertion flag

% Save the recon parameters for future reference
save Params reconParams ;  

% Perform PET reconstruction
img = GEPETrecon(reconParams) ;


%% Recon with MRAC using inserted lesion data 
MRACreconWithLesionDir = [baseDir '/MRACreconWithLesion']; % working directory for recon
mkdir(MRACreconWithLesionDir);
cd(MRACreconWithLesionDir);
system(sprintf('cp -r %s .',PETrawDir)); % Copy PET raw data
system(sprintf('cp %s/rdf.1.1.pifa* .',MRACpifaDir)); % Copy rdf.1.1.pifa_comp and rdf.1.1.pifa_ivv from registered CT based AC
system(sprintf('ln -s %s/LesionProjs_frame1 LesionProjs_frame1',CTreconDir)); % Link the inserted lesion sinogram data

reconParams = DBmake_GEPETreconParams('EV')  ; % EV -> Everest -> PETMR
reconParams.algorithm          = 'TOFOSEM'   ; 
reconParams.MRAC.AnatomyID     = ['LH']      ; 
reconParams.MRAC.pseudoCTflag  = 0           ; % Read pseudoCT from pseudoCT directory!
reconParams.MRAC.HNSpecial     = 0           ; % Do not run dedicated H&N MRAC  
reconParams.postFilterFWHM    = 3           ; % [MK] Transxial post-filter FWHM specification
reconParams.zfilter           = 6           ; % [MK] Axial post-filter strength    (4 = standard; 0 = no filter; 2 = heavy; 6 = light)
% La pitie recon params
reconParams.numIterations     = 4;
reconParams.numSubset         = 0; % 28 subsets
reconParams.nx                = 256;
reconParams.ny                = 256;
reconParams.detectorResponseFlag = 2; %PSF on    
reconParams.MRAC.TruncComplete = 0           ; 

reconParams.lesionInsertionTOFFlag = 1; % Lesion insertion flag

% Save the recon parameters for future reference
save Params reconParams ;  

% Perform PET reconstruction
img = GEPETrecon(reconParams) ;


%% Example analysis
CTACimg = readSavefile(sprintf('%s/ir3d.sav',CTreconWithLesionDir)); % CTAC image with inserted lesion
MRACimg = readSavefile(sprintf('%s/ir3d.sav',MRACreconWithLesionDir)); % MRAC image with inserted lesion

CTACval = mean(CTACimg(lesionBinaryMask)); % ROI quantitation for CTAC image
MRACval = mean(MRACimg(lesionBinaryMask)); % ROI quantitation for MRAC imag
trueVal = mean(trueImg(lesionBinaryMask)); % Ground truth ROI quantitation

RC_CTAC = CTACval/trueVal; % Recovery coefficient for CTAC -> 94.55%
RC_MRAC = MRACval/trueVal; % Recovery coefficient for MRAC -> 91.96%


