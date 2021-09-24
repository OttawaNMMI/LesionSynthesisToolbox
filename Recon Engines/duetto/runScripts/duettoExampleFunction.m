function  reconImage = duettoExampleFunction(dataDir, reconDir, ...
    reconAlgorithm, fov, matrix, iterations, subsets, beta, ...
    filterT, filterZ)
%
% INPUTS
%    - dataDir: FULL PATH to the location of the data directory.
%               It must contain:
%                  - raw data directory (with .img DICOM files)
%                  - PIFA files or MRAC/CTAC image directory
%                      - the MRAC folder must contain sub-directories
%                        InPhase-X, FAT-X, WATER-X, where X is the frame number
%    - reconDir: optional input, full path to where results will be saved;
%                a subdirectory "workDir" will be created based on reconDir
%                and reconAlgorithm inputs.  This can be modified by the
%                user. Links to raw data and other files/directories are
%                created in this workDir subdirectory.
%    - reconAlgorithm: options = OSEM, OSEM-PSF, TOFOSEM, TOFOSEM-PSF, BSREM, TOFBSREM
%    - other inputs will directly modify userConfig default parameters;
%                they can be modified belo and others can be added.
%
% EXAMPLES
%    - Create recon folder in different directory from where the data is located:
%      reconImage = duettoExampleFunction('/data/exam1234','/data/exam1234', ...
%                   	'TOFOSEM-PSF',600,128,2,32,100,5,4);
%
%    - Create recon folder in same directory from where the data is located:
%      reconImage = duettoExampleFunction('/data/exam1234','', ...
%                       'TOFBSREM',600,128,2,32,100,5,4);
%
%        Directories defined:
%           reconDir = /data/exam1234
%           dataDir  = /data/exam1234
%           workDir  = /data/exam1234/OSEM
%
%        Links to following files/dirs are made in the workDir (if they exist):
%           patientRawDir = /data/exam1234/raw
%           mracImageDir  = /data/exam1234/MRAC
%           ctacImageDir  = /data/exam1234/CTAC
%           tofnacDir     = /data/exam1234/TOFNAC
%           rdfCompFile   = /data/exam1234/pifa_f1b1.pifa
%           rdfIvvFile    = /data/exam1234/pifaIvv_f1b1.pifa
%
% NOTES
%    - Make sure duettoMracFiles are in default path, or define using userConfig.mracExtDir
%    - Define dataDir and reconDir (if used) as FULL PATHS
%    - User-defined iterations, subsets, filterT, filterZ are not used for BSREM
%    - User-defined beta not used for OSEM algorithms
%
% Copyright 2018 General Electric Company.  All rights reserved.



% If the location of the data and location of recon are same, just pass one
if isempty(reconDir)
    reconDir = dataDir;
end


%% Add Duetto toolbox to MATLAB path
addpath(genpath(duettoToolboxLocation))


%% Create new directory for this reconstruction, change to new directory
workDir = fullfile(reconDir, reconAlgorithm);
if ~exist(workDir,'dir')
    mkdir(workDir)
end
cd(workDir);


%% Define patient data and recon info, create links
% Need raw data & PIFAs from scanner
% If PIFAs not provided, then need MRAC/CTAC images to generate PIFAs.
% MRAC also requires TOFNACs if frames require Truncation Completion;
% if TOFNACs are not provided, they will be generated.
% MRAC folder requires sub-folders FAT-X, WATER-X, InPhase-X,
% and ZTE-X (optional), where X = frame number
patientRawDir = fullfile(dataDir,'raw');
mracImageDir  = fullfile(dataDir,'MRAC');
ctacImageDir  = fullfile(dataDir,'CTAC');
tofnacDir     = fullfile(dataDir,'TOFNAC');

% Link to raw data; must have!  Only link if it does not yet exist.
if ~exist('raw','dir')
    system(sprintf('ln -sf %s raw', patientRawDir));
end

% Link to MRAC or CTAC directories if they exist (and links not yet made)
system('unlink MRAC'); system('unlink CTAC')
if exist(mracImageDir,'dir') && ~exist(fullfile(workDir,'MRAC'),'dir')
    system(sprintf('ln -sf %s %s/MRAC', mracImageDir, workDir));
    attenDataDir = mracImageDir;
elseif exist(ctacImageDir,'dir') && ~exist(fullfile(workDir,'CTAC'),'dir')
    system(sprintf('ln -sf %s %s/CTAC', ctacImageDir, workDir));
    attenDataDir = ctacImageDir;
end

% Link PIFA files & TOFNACs using Duetto structure (if they exist);
% Duetto file format: pifa_fXbY.pifa, pifaIvv_fXbY.pifa, where X=frame#, Y=bin#
% Can modify to use petRecon format: rdf.X.Y.pifa_comp, rdf.X.Y.pifa_ivv
% Must modify for multiple f=frames (bed positions) vs multiple b=bins (dynamic series)
rawDirFiles = dir(patientRawDir);
numRawFiles = length(strfind([rawDirFiles.name],'.img')) - 3;
for numFrame = 1:numRawFiles
    % Define PIFA full path and filename
    pifaFile    = sprintf('%s/pifa_f%db1.pifa',    dataDir, numFrame);
    pifaIvvFile = sprintf('%s/pifaIvv_f%db1.pifa', dataDir, numFrame);
    
    % Like PIFAs if the file exists
    if exist(pifaFile,'file')
        system(sprintf('ln -sf %s pifa_f%db1.pifa',    pifaFile,    numFrame));
        system(sprintf('ln -sf %s pifaIvv_f%db1.pifa', pifaIvvFile, numFrame));
    end
    
    % Link TOFNAC if needed (and they exist)
    tofnacDir = sprintf('%s-%d', tofnacDir, numFrame);
    if exist(tofnacDir,'dir')
        system(sprintf('ln -sf %s TOFNAC-%d', tofnacDir, numFrame));
    end
end


%% Generate default user configuration
% Only reconAlgorith needs to be based in. See ptbUserConfig for defaults.
isComet = 0; % Optional input to ptbUserConfig; Default = 0
userConfig = ptbUserConfig(reconAlgorithm, patientRawDir, attenDataDir, workDir, isComet);


%% Specify any values different from default (this can be nothing or lots of things)
% They will be populated to appropriate config structure (e.g. reconParams, scatterParams)

% Calculate corrections (or not)
%userConfig.computeAttenuationFlag = true;
%userConfig.computeRandomsFlag = true;
%userConfig.computeScatterFlag = true;

% Use corrections (or not)
%userConfig.attenCorrFlag      = false;
%userConfig.randomsCorrFlag    = false;
%userConfig.normDtPucCorrFlag  = false;
%userConfig.scatterCorrFlag    = false;

% Reconstruction parameters
%userConfig.frames = 1;          % Specify frames, [1:3] or [1 3]; if [], will process all
userConfig.nX = matrix;         % nY is populated based on nX
userConfig.radialFov = fov;     % Unit is mm
userConfig.nIterations = iterations;
userConfig.nSubsets = subsets;
userConfig.postFilterFwhm = filterT;
userConfig.zFilter = filterZ;
userConfig.beta = beta;
%userConfig.keepIterationUpdates = 1;
%userConfig.keepSubsetUpdates = 0;
userConfig.workFileFormat = 'sav';  % 'mat' or 'sav'

% MRAC parameters
%userConfig.headMracMethodFlag = 1;   % 1=Atlas, 2=Partial Head, 3=ZTE
%userConfig.truncComplete = 1;        % 0 vs 1

% General parameters
userConfig.nParallelThreads = 1;                % Maximum number of threads to use
userConfig.verbosity = PtbVerboseEnum.VERBOSE;  % Level of detail to print to screen
userConfig.writeDicomOutputFlag = 1;            % Write final image as a dicom file (in addition to ir3d.sav)


%% Run corrections and recon
reconImage = ptbRunRecon(userConfig);


