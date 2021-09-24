function userConfig = ptbUserConfig(reconAlgorithm, petDataDir, ...
    attenDataDir, workDir, isComet)
% FILENAME: ptbUserConfig.m
% 
% PURPOSE: Set default user configuration parameters 
%          *** See user guide for other parameters that can be defined ***
%
% INPUTS:
%   reconAlgorithm : 'OSEM, 'OSEM-PSF', 'TOFOSEM', 'TOFOSEM-PSF', 
%                    'BSREM', 'TOFBSREM' (BSREM and TOFBSREM include PSF)
%   petDataDir     : Full path to raw DICOM, e.g. '/localdata/anon01/raw'
%   attenDataDir   : Full path to CTAC/MRAC, e.g. '/localdata/anon01/CTAC'
%   workDir        : Full path to output files, e.g. '/localdata/anon01'
%   isComet        :  true for Comet/Discovery IQ; false for other scanners [default: false]
%
% OUTPUT:
%   userConfig: A struct with default parameters that is used to intialize 
%               data correction and image reconstruction parameters
%
% Copyright 2019 General Electric Company.  All rights reserved.


%% Populate input parameters with defaults if not passed in
if ~exist('reconAlgorithm', 'var')
    reconAlgorithm = 'OSEM';
end
if ~exist('workDir', 'var')
    workDir = pwd;
end
if ~exist('petDataDir', 'var')
    petDataDir = fullfile(workDir,'raw');
end
if ~exist('attenDataDir', 'var')
    attenDataDir = []; % will be set once scannerName is known
end
if ~exist('isComet', 'var') || isempty(isComet)
    isComet = false;
end


%% Scanner and algorithm dependent parameters 
userConfig = PTB_RECON_DEFAULT(reconAlgorithm, isComet);


%% Data preparing flags
userConfig.scannerDataFlag = true;
userConfig.workDir      = workDir;
userConfig.petDataDir   = petDataDir;
userConfig.attenDataDir = attenDataDir;
userConfig.workFileFormat = '.sav';

% Location of MRAC templates and executables directory
userConfig.mracExtDir = fullfile(duettoToolboxLocation,'..','duettoMracFiles');


%% Recon flag and parameters
userConfig.initialImageFile = '';
userConfig.nX = 192;
% userConfig.nZ = [];      % determined by sysConfig
% userConfig.frames = [];
% userConfig.bins = [];
% useConfig.radialFov;


%%  Work flow controls 
userConfig.extractDataFlag    = true;
userConfig.genCorrectionsFlag = true;
userConfig.runReconFlag       = true;

% Parallel reconstructions: max number of workers, 0 or 1 = no parallel recon
userConfig.nParallelThreads = 1;

% Print out verbosity: VERBOSE, DETAILED, CONCISE, TERSE
userConfig.verbosity = PtbVerboseEnum.DETAILED;


%% Flags to control individual correction modules
userConfig.computeRandomsFlag     = true;
userConfig.computeNormFlag        = true;
userConfig.computeDtPucFlag       = true;
userConfig.computeAttenuationFlag = true;
userConfig.jointEstimationFlag    = false;
userConfig.computeScatterFlag     = true;
userConfig.randomsUserFunc = '';
userConfig.normUserFunc    = '';
userConfig.dtPucUserFunc   = '';
userConfig.attenUserFunc   = '';
userConfig.scatterUserFunc = '';


%% FOV offset, choose one of the two methods, don't set both!
% 1) FOV offset in DICOM LPS patient coordinates 
userConfig.lTarget = 0;  % FOV offset, Left/Right in DICOM LPS patient coordinates
userConfig.pTarget = 0;  %             Posterior/Anterior (units: mm)
% 2) FOV offset in scanner system XYZ coordinates, 
% ptbConfig.xTarget = 0; 
% ptbConfig.yTarget = 0;


%% Recon and recon correction parameters
userConfig.keepIterationUpdates = 1;
userConfig.keepSubsetUpdates    = 0;
userConfig.decayCorrFlag        = 1;
userConfig.durationCorrFlag     = 1;
userConfig.randomsCorrFlag      = 1;
userConfig.normDtPucCorrFlag    = 1;
userConfig.scatterCorrFlag      = 1;
userConfig.attenCorrFlag        = 1;

userConfig.useSavedSensitivityImages = 0; % used in TOF algorithms;
userConfig.saveSensitivityImages     = 0; % option to save for future recons



%% Post processing parameters
userConfig.outputFilename = 'ir3d';

% Post-filtering
userConfig.postFilterFwhm = 0;
userConfig.zFilter = 0;

% DICOM write
userConfig.writeDicomOutputFlag = true;
userConfig.dicomSeriesNumber = 801;
userConfig.dicomSeriesDesc = 'offline3D';

