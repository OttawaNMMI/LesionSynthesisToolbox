% LesionInsertion_TOFV4 - This function genrated the lesion projection
% files and reconstructs the target image with the synthesic lesions 
%
% To generate the projection files, a reconstruction
% of the target patient data is needed to (revert) take the inverse of any
% corrections applied on the lesion projection data. The preliminary recon
% must be generated using indentical recon parameters as the target image
% and therefore a single lesion synthesis is only applicable for the
% reconsruction parameters it was generated with. Once the preliminary
% recon is complete (Baseline_PET), a secondary directory is generated 
% and necessary files are copied over. 
%
% The second recon is initialized where during the
% reconstruction take individal projections of the lesion(s) are combined
% with projections of the target patient data. The image with synthetic
% lesions are stored in the secondary directory (CTreconWithLesion)
%
% To modify the recon parametrs used: LesionInsertion_GEPETreconParams
%
% Lesion Synthesis at this time is only supported using the GE RECON 
% TOOLOX (VER: REGRECON5) for Time-of-flight reconstructions. For
% development/modifications/access to source code please contact 
% GE Healthcare PET image reconstrcution development team 
% (As of early 2019: Michael.Spohn@ge.com)
%
% This function uses tools from the GE RECON TOOLBOX (REGRECON5) and
% therefore needs REGRECON5 in the available directory
%
% Usage: 
% ======
% LesionInsertion_TOFV4(reconName,lesionImg,patdatadir,LIparams)
%
% reconName = 'LesionInsertionExampleEmptyScan_TOF_Test';
%
% lesionImg - matrix describing image with indicies in units of Bq/cc
%
% patdatadir - Typically this folder should have two
% stored directies within. The first is a CTAC folder with the slices of
% the patient CTAC image used to ATTEN CORR by the GE RECON TOOLBOX.
%
% LIparams - generated in previous caller function but a cell describing
% the following parameters: 
%         LIparams.copyFiles = 1; yes, unless its already present in the
%         necessary directories (used to debugging or crash situations) 
%
%         LIparams.baselineRecon = 1; ye , dont need if data was generated in
%         final lesion + patient recon parameters
%
%         LIparams.genLesionFiles = 1; yes gen lesion projections
%
%         LIparams.mainFS = 1; Only for Linux Box Needs to run on the disk
%         with the OS and not other HD?? (most likely a formating error)
%
% Next Step: LesionInsertion_TOFV4
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2018
% Last Modified: April 30 2019

function LesionInsertion_TOFV4(reconName,lesionImg,patdatadir,LIparams,reconDir)

copyFiles = LIparams.copyFiles;
baselineRecon = LIparams.baselineRecon;
genLesionFiles = LIparams.genLesionFiles; 
mainFS = LIparams.mainFS; 

% Set the important dirs for this simulation
if isempty(reconName) 
    reconName = ['LesionInsertion - ' datestr(now)]; 
end 


if isempty(patdatadir)
	% Really not necessary...early stage development...but here anyways
    if ~mainFS %Main File System (Linux Errors)
        reconDir = '/media/hanif/HANIFHDD/Lesion_Synthesis_Code/Simulation/'; % Where to save all generated files
        PETrawDir = '/media/hanif/hdd/GE_710_DATA/Console_Data/October2018/Empty3BedPosPETCT/raw/'; % RAW PET data
        CTfiles = '/media/hanif/hdd/GE_710_DATA/Console_Data/October2018/Empty3BedPosPETCT/CTAC/'; % CT data
    else
        reconDir = '/home/hanif/Documents/TOFLesionInsertion_MainFSystem/';
        PETrawDir = '/home/hanif/Documents/TOFLesionInsertion_MainFSystem/October2018/Empty3BedPosPETCT/raw/'; % RAW PET data
        CTfiles = '/home/hanif/Documents/TOFLesionInsertion_MainFSystem/October2018/Empty3BedPosPETCT/CTAC/'; % CT data
    end
else % THIS IS THE GOOD STUFF =)
        %reconDir = '/home/hanif/Documents/TOFLesionInsertion_MainFSystem/';
        %reconDir = 'C:\Users\hjuma\Documents\MATLAB\Lesion Synthesis DB'; 
        PETrawDir = [patdatadir filesep 'raw' filesep]; 
        CTfiles = [patdatadir filesep 'CTAC' filesep]; 
end


basedir = [reconDir filesep reconName];
% Create Dir for all simulation related files
mkdir([reconDir filesep reconName])

% Create Dir for BASELINE PET TOF Recon
bPETdir = [reconDir filesep reconName filesep 'Baseline_PET'];
mkdir(bPETdir)
mkdir([bPETdir filesep 'raw']);
mkdir([bPETdir filesep 'CTAC']);

% Copy the necessary files to Baseline PET dirs
if copyFiles
%% New HJUMA Modification Feb 1 2019 
copyfile(patdatadir,bPETdir)

else
    disp(['User specified not to copy RAW PET & CT files'])
end

% Change workspace to Baseline PET recon dir
cd(bPETdir)

if baselineRecon
    % Define and save the recon parameters
    reconParams = LesionInsertion_GEPETreconParams; % gen Default LI Params
    reconParams.genCorrectionsFlag = 1; %Turn Corrections on
    save([bPETdir filesep 'ReconParams.mat'],'reconParams')
    
    % Perform a PET recon with Attenuation Correction [GT: Patient without Lesion]
    img = GEPETrecon(reconParams);
else
    if exist([bPETdir filesep 'ReconParams.mat'])
        load([bPETdir filesep 'ReconParams.mat'])
    else
        warning('Cannot Pull Recon Params - Might be okay since no baseline Recon')
    end
end

%% Create Lesion Image
if isempty(lesionImg) 
    img = readSavefile([bPETdir filesep 'ir3d.sav']);
    
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
    
end

%% Lesion insertion: create (Poisson-noisy) lesion sinogram in /LesionProjs_frame1
if genLesionFiles 
% The same recon params as used in recon
reconParams = LesionInsertion_GEPETreconParams; % "TOFOSEMS" incorporates PSF

%% IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!
% Good idea to generate the corrections here..unless the directory where
% the target image is stored used the same recon params you need for your
% image with the synthesic lesions
reconParams.genCorrectionsFlag = 1;
reconParams.dicomImageSeriesDesc = 'Perception_Liver_Offline_3D';   % No spaces allowed


% Lesion insertion flag 
reconParams.lesionInsertionTOFFlag = 1;

% Generate Poisson-noisy lesion sinogram in /LesionProjs_frame1
lesionInsertion(lesionImg,reconParams);
end 

%% Recon with registered CT AC using inserted lesion data
CTreconWithLesionDir = [basedir '/CTreconWithLesion']; % working directory for recon
mkdir(CTreconWithLesionDir);
cd(CTreconWithLesionDir);

%copyfile(patdatadir,CTreconWithLesionDir); 
copyfile(bPETdir,CTreconWithLesionDir); 
system(sprintf('cp -r %s .',PETrawDir)); % Copy PET raw data
system(sprintf('cp -r %s .',CTfiles));

% Link the TOF Lesion Sinogram Data 
for i = 1:8 % Hard Coded 8 bed positions (find a better way please)     
    
	LesProjName = ['LesionProjs_frame' num2str(i)]; 
    
    if exist([bPETdir filesep LesProjName],'dir')
        mkdir(CTreconWithLesionDir,LesProjName)
        copyfile([bPETdir filesep LesProjName],[CTreconWithLesionDir filesep LesProjName])
        disp(['Linked ' LesProjName])
    end 
    
end 

reconParams = LesionInsertion_GEPETreconParams; 
reconParams.dicomImageSeriesDesc = 'Synthetic_Lesion_Offline_3D';
reconParams.lesionInsertionTOFFlag = 1; % Lesion insertion flag
reconParams.genCorrectionsFlag = 0; 

% Save the recon parameters for future reference
save Params reconParams ;

% Perform PET reconstruction
img = GEPETrecon(reconParams);

end