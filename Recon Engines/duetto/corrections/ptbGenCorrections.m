function corrParams = ptbGenCorrections(generalParams, corrParams, ...
    scanner, sinoParams, frameStats)
% Generate PET correction data


%% Identify FTR units
if corrParams.ftrParams.ftrCorrFlag || corrParams.ftrParams.ftrDetectFlag
    fprintf('Detecting outlier detector units for FTR compensation\n');
    corrParams = ptbInitializeFtr(generalParams, corrParams, scanner, frameStats);
end


%% Compute randoms
if corrParams.computeRandomsFlag    
    if isempty(corrParams.randomsUserFunc)
        randomsFunc = 'ptbComputeRandoms'; % default 
    else
        randomsFunc = corrParams.randomsUserFunc;
    end
    fhRandoms = str2func(randomsFunc);
    fprintf('Computing randoms sinogram using %s\n', randomsFunc);
    fhRandoms(generalParams, corrParams.randomsParams, sinoParams, frameStats);
end


%% Compute norm
if corrParams.computeNormFlag
    if isempty(corrParams.normUserFunc)
        normFunc = 'ptbComputeNorm'; % default 
    else
        normFunc = corrParams.normUserFunc;
    end
    fhNorm = str2func(normFunc);
    fprintf('Computing normalization sinograms using %s\n', normFunc);
    fhNorm(generalParams, scanner, sinoParams);
end


%% Compute dtPuc
if corrParams.computeDtPucFlag
    if isempty(corrParams.dtPucUserFunc)
        dtPucFunc = 'ptbComputeDeadtimePuc'; % default 
    else
        dtPucFunc = corrParams.dtPucUserFunc;
    end
    fhDtPuc = str2func(dtPucFunc);
    fprintf('Computing deadtimePuc sinograms using %s\n', dtPucFunc);
    fhDtPuc(generalParams, corrParams.dtPucParams, scanner, sinoParams, frameStats);
end


%% Compute attenuation
if corrParams.computeAttenuationFlag
    % Decide if it is MRAC or CTAC
    if isempty(corrParams.attenUserFunc)
        if strcmpi(scanner.name, 'PETMR')
            attenFunc = 'ptbComputeMrac';
        else
            attenFunc = 'ptbComputeCtac';
        end
    else
        attenFunc = corrParams.attenUserFunc;
    end
    fhAtten = str2func(attenFunc);
    fprintf('Computing PIFA images and attenuation sinograms using %s\n', attenFunc);
    fhAtten(generalParams, corrParams.attenParams, scanner, sinoParams, ...
        corrParams.ftrParams, frameStats);
elseif corrParams.computeScatterFlag && isempty(dir('acf*sav'))
    % If attenuation not computed and doesn't exist, but scatter is requested, error
    error('Attenuation map does not exist, and it is required to compute scatter correction');
end


%% Compute scatter
if corrParams.computeScatterFlag
    if isempty(corrParams.scatterUserFunc)
        scatterFunc = 'ptbComputeScatter';
    else
        scatterFunc = corrParams.scatterUserFunc;
    end
    fhScatter = str2func(scatterFunc);
    fprintf('Computing scatter sinograms using %s\n', scatterFunc);
    fhScatter(generalParams, corrParams.scatterParams, scanner, ...
        sinoParams, corrParams.ftrParams, frameStats);
end
