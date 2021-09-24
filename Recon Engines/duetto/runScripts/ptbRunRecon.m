function reconImg = ptbRunRecon(userConfig)

%% Initialize general parameters
generalParams = ptbInitGeneralParams(userConfig);


%% Extract PET data from scanner files
if userConfig.scannerDataFlag
    % Extract PET data
    [generalParams, rdfFilenames, calFilenames, rpdcInfo] = ptbExtractPetData(generalParams);
    
    % Initialize parameters
    [generalParams, reconParams, corrParams, scanner, sinoParams, frameFiles, keyholeParams, ...
        ~] = ptbInit(generalParams, rdfFilenames, calFilenames, rpdcInfo, userConfig);
    
    % Extract Frame Data and Stats
    frameStats = ptbExtractFrameData(generalParams, rpdcInfo, rdfFilenames, ...
        scanner, sinoParams, frameFiles);
    reconParams.frameOverlap = round(sinoParams.nZ-abs(frameStats(1).frameOffset)/sinoParams.sV);
end


%% Check parameter and data consistency
% This section not yet implemented
% ptbCheckConfig(frameStats, corrParams, reconParams);


%% Data corrections
corrParams = ptbGenCorrections(generalParams, corrParams, scanner, sinoParams, frameStats);


%% Run image reconstruction
if userConfig.runReconFlag
    reconImg =  ptbPetRecon(generalParams, reconParams, keyholeParams, ...
        scanner, sinoParams, corrParams.ftrParams, frameStats);
else
    reconImg = [];
end


%% File clean-up
ptbFileCleanup(generalParams.filesToKeep)
