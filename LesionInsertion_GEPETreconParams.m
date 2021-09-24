% ==================================================================%
% Copyright (c) General Electric Company. All rights reserved.
%
% This code is only made available outside the General Electric Company
% pursuant to a signed Research Agreement between the Company and the
% institution to which the code is made available. The code and all
% derivative works thereof are subject to the non-disclosure terms of
% said Research Agreement.
%
% FILE NAME: GEPETreconParams.m
%
% This file creates a reconParams structure in lieu of a GUI-generated one
%
% INPUTS:
%       n/a
%
% OUTPUTS:
%       reconParams: Structure defining the reconstruction parameters. 
%

%   History:
%   ?/?/?   Written by ?
%   06/28/2012  MT  -  Added ctacInVivoFilename field to reconParams
%==========================================================================
function [reconParams] =  LesionInsertion_GEPETreconParams

reconParams.dir = [pwd filesep];
reconParams.dicomImageSeriesDesc = 'Offline_3D';   % No spaces allowed. Will also be
                                                    % used as directory name
reconParams.dicomImageSeriesNum =  801;

%% MAIN WRAPPER PARAMETERS
reconParams.rawFromDicomFlag = 1;
reconParams.genCorrectionsFlag = 0;
reconParams.reconFlag = 1;              % 0: No Recon  1: IR Recon  2:
reconParams.writeDicomImageFlag = 1;	 % 0: No Write  1: Write Dicoms
reconParams.startFrame = 1;             % First frame to process
% reconParams.endFrame = 999;             % Last frame to process 
                                        % (if nFrames < endFrame, endFrame = nFrames
                                       
reconParams.simulation = 0; % 0 - not a simulation recon
%% CORRECTION MODULE PARAMETERS
%FLAGS FOR CORRECTIONS
reconParams.decayFlag = 1;              % 0: No correction 1: Decay 
reconParams.randomsFlag=1;              % 0: No correction 1: RFS            2: Delays
reconParams.normDeadtimeFlag = 1;
reconParams.deadtimeFlag=2;             % 0: No correction 1: Deadtime only  2: Deadtime with PUC
reconParams.normalizationFlag = 1;
reconParams.scatterFlag = 2;            %Set to 1 for 2DSuperSlices in MBSC, set to 2 for 3DSuperslices % Usually 0 for lesion synthesis 
reconParams.attenuationFlag = 1;
reconParams.CTACSinoFlag = 0;           %Set to use old style CTAC Sinograms (prePIFA)
reconParams.PIFAfromCTFlag = 1;         %Set to 1 to generate PIFAs from CT images (most common)
reconParams.PIFAfromProductFlag = 0;    %Set to 1 to generate PIFAs from product PIFA files (AAAA*_)

% FILENAMES: OUTPUT OF PREPROCESSING AND INPUTS TO RECON 
reconParams.intermediateFileFormat = 'sav'; % Choices: 'sav' 'mat'
reconParams.emFilename       = fullfile(reconParams.dir, 'prompts');
reconParams.scatterRRfilename  = fullfile(reconParams.dir, 'scatterRR');
reconParams.scatterNGfilename  = fullfile(reconParams.dir, 'scatterNG');
reconParams.randomsFilename  = fullfile(reconParams.dir, 'randoms');
reconParams.acfFilename      = fullfile(reconParams.dir, 'ctac');
reconParams.normFilename     = fullfile(reconParams.dir, 'norm');
reconParams.deadtimeFilename = fullfile(reconParams.dir, 'deadtime');
reconParams.normDeadtimeFilename = fullfile(reconParams.dir, 'normDeadtime');
reconParams.decayFilename = fullfile(reconParams.dir, 'decay');
reconParams.durationFilename = fullfile(reconParams.dir, 'duration');
reconParams.ctacInVivoFilename = fullfile(reconParams.dir, 'ctac_ivv');   % added by MT on 06/28/2012
reconParams.inputFilename = fullfile(reconParams.dir, 'rdf');   % added by MT on 07/12/2012
reconParams.CTACconvFile =	'ctacConvScale_rev5.cfg' ;  % D600 D690
reconParams.normImagesFilename = fullfile(reconParams.dir, 'normImages');
%reconParams.CTACconvFile           ='ctacConvScale.cfg' ;  % DST DSTE DRX DVCT
%TOF PARAMETERS
reconParams.emFilenameRDFTOF       = fullfile(reconParams.dir, 'rdf');
reconParams.dsScatterFilenameTOF = [reconParams.dir 'dsTOFscatterUpPhi.tof'];
reconParams.scatterNormFilenameTOF=[reconParams.dir 'scatternorm'];
reconParams.mbscParams4TOFreconFilename=[reconParams.dir 'mbscParams4TOFrecon'];
reconParams.tRes = 675;
reconParams.timeMash = 1;

% reconstructed image filename
reconParams.imOutFilename= fullfile(reconParams.dir, 'ir3d');


%% RECONSTRUCTION MODULE PARAMETERS
reconParams.FOV = 700;
reconParams.xOffset = 0;		%Units: mm
reconParams.yOffset = 0;		%Units: mm
reconParams.nx = 192;
reconParams.ny = 192;
reconParams.nz = 47;

%OSEM RECONSTRUCTION CORRECTION PARAMETERS
reconParams.scatterCorrFlag = 2;        % scatter correction 0: No correction, 1: Pre correction 2: loop correction
reconParams.randomsCorrFlag = 2;        % randoms correction 0: No correction, 1: Pre correction 2: loop correction
reconParams.acfCorrFlag = 2;            % attenuation correction 0: No correction, 1: Pre correction 2: loop correction
reconParams.normDeadtimeCorrFlag = 2;
reconParams.durationCorrFlag = 2;		    %decay correction =0; No correction. 1: Post correction 2: loop correction	 	
reconParams.decayCorrFlag = 2;		    %duration correction =0; No correction. 1: Post correction 2: loop correction	 	
reconParams.radialRepositionFlag = 0;
reconParams.detectorResponseFlag = 1;

%OSEM SETTINGS AND FILTER SETTINGS
reconParams.algorithm = 'TOFOSEM';         % Options are 'OSEM' or 'BSREM'
reconParams.numSubsets = 24;             % Set to 0 or comment out to use default
reconParams.numIterations = 2;          % Number of iterations
reconParams.startSubset = 1;            % Start subset
reconParams.startIteration = 1;         % Start iteration
reconParams.keepSubsetUpdates = 0;      % Store intermediate results after each subset
reconParams.keepIterationUpdates = 0;   % Store intermediate results after each iteration
reconParams.postFilterFWHM = 0; %3 ;%[1/6,4/6,1/6];         % FWHM for gaussian post filter, Units: mm
reconParams.zfilter = 0; %6 ; %6;                % Center weighted for 3-point center weighted averager.

reconParams.prior = 'rdp';
reconParams.beta = 350;
reconParams.penParams = 2;
reconParams.nonTOFalpha0 = 2.0;
reconParams.TOFalpha0 = 1.2;
reconParams.gamma = 0.2; 

reconParams.axiallyModulatedSmoothingFlag = 1;
reconParams.transaxiallyModulatedSmoothingFlag = 1;
reconParams.dataDependentTransaxialModulation=0;
reconParams.percentPSFmodeling = 100;

%PETflag = input('Please enter 0 for PET-CT or 1 for PET-MR: ');
PETflag = 0;
if PETflag  % only for PET-MR
    reconParams.tRes = 420;
    reconParams.FOV = 600;
    reconParams.nz = 89;
    reconParams.normDeadtimeFlag = 0; %%1      % DEADTIME CURRENTLY NOT READY!
    reconParams.deadtimeFlag=0;    %%2         % 0: No correction 1: Deadtime only  2: Deadtime with PUC
    reconParams.normalizationFlag = 1;
    reconParams.normDeadtimeCorrFlag = 2;
    reconParams.writeDicomImageFlag=1;
    reconParams.rawFromDicomFlag=0;
    reconParams.attenuationFlag = 2;    % 0: No correction   1: CTAC   2: MRAC
    reconParams.geoCalFilename = '/petphys3/media/disk-1/tohme/simset/PETMR/Norm/Norm_PETMR_geoCal2D_600FOV.1.1.sav';
    %TEMPORARY FIX FOR NORM!
    if ( (~exist(fullfile(reconParams.dir,'norm3d'), 'file')) & (reconParams.normDeadtimeCorrFlag>0) )
        normFileName = [reconParams.normFilename '.' reconParams.intermediateFileFormat];
        if (~exist(normFileName, 'file'))
            % CHANGE THE FOLLOWING NORM FILE IF NEEDED
            fprintf('Warning: Normalization file %s not found!\nAssigning new normalization file: ',normFileName);
            reconParams.normFilename = '/petphys3/media/disk-1/tohme/simset/PETMR/Norm/600FOV/geo3Dpsm_effLaBestia';
            fprintf('%s.sav\n',reconParams.normFilename);
        end
    end
end

end 
