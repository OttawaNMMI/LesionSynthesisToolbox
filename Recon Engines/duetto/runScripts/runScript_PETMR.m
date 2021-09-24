
% Simple script to run PET image reconstruction for scanner data
% Instructions
% 1. Make a work directory and copy this file to the work directory with a 
%    new name (e.g, myReconScript01.m) 
% 2. Specify
%      petDataDir     : PET raw DICOM data directory 
%      attenDataDir   : MRAC DICOM image directory (optional if have PIFAs)
%      reconAlgorithm : OSEM-PSF, TOFOSEM, TOFOSEM-PSF, BSREM, TOFBSREM
%      Note: For truncation completion or phantom studies, recommended to 
%            have TOFNAC-N to workDir
% 4. Modify userConfig fields as desired
% 5. Go to the work directory in MATLAB, run the script 


%% Define paths and algorithm
workDir         = pwd;                       % full path of output directory
petDataDir      = fullfile(workDir,'raw');   % full path to PET raw data
attenDataDir    = fullfile(workDir,'MRAC');  % full path to MRAC data
reconAlgorithm  = 'OSEM'; 


%% Generate user configuration 
userConfig = ptbUserConfig(reconAlgorithm, petDataDir, attenDataDir, workDir);

% Customize by editing the fields of userConfig, e.g.
% userConfig.nX = 256;   % number of pixels in X-dimension of recon image 


%% Call recon: generate corrections and perform recon
reconImage = ptbRunRecon(userConfig);
