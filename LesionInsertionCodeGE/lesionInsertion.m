function lesionInsertion(reconImg,reconParams,SD)
% FILENAME: lesionInsertion.m
%
% Generate TOF lesion sinogram data with Poisson noise
%
% Input:
%   reconImg: lesion image
%   reconParams: reconParams structure defining reconstruction setting
%   SD: Optional. Random number seed.
%
% Output:
%   TOF lesion sinogram data are saved in /LesionProjs_frame*
%
% The given lesion image ('reconImg') is forwared-projected considerting
% attenuation, normalization, PSF, decay and scan duration. Poisson noise
% is added.
%
% Copyright 2017 General Electric Company. All rights reserved.

% History:  10/10/2017  Written by SA

if exist('SD','var')
    rng(SD)
end

reconParams.lesionInsertionTOFFlag = 1;
reconParams.randomsFlag = 0;
reconParams.scatterFlag = 0;

%% extract data from Dicom
if (reconParams.rawFromDicomFlag)
    RPDCInfo=sortRawDicomBinned('./rdf', './', './raw/*RPDC*');
    reconParams.frameOffset = RPDCInfo.frameOffset;
    reconParams.nFrames=RPDCInfo.numBedPositions;
    reconParams.nBins=RPDCInfo.numGates * RPDCInfo.numTimeFrames/RPDCInfo.numBedPositions;
    warning('HGJ had to comment stuff out to make this work')
    %reconParams.patientWeight=RPDCInfo.PatientWeight;
    %reconParams.sliceSeparation = RPDCInfo.sliceSeparation;
    % read one RDF and set system details etc
    rdf=readRDF('rdf.1.1', false);
elseif exist([reconParams.inputFilename '.1.1'],'file')
    rdf=readRDF([reconParams.inputFilename '.1.1'],false);
    %opp = sprintf('mv %s %s.1.1',reconParams.inputFilename,reconParams.inputFilename);
    %system(opp);
    reconParams.frameOffset = 0;  %NEEDS TO BE CHANGED
    reconParams.nFrames=1;       %NEEDS TO BE CHANGED
    reconParams.nBins=1;        %NEEDS TO BE CHANGED
else
    if exist('SINO0000','file')
        rdf=readRDF('SINO0000',false);
        reconParams.inputFilename = [reconParams.dir 'rdf'];
        system('mv SINO0000 rdf.1.1');
        reconParams.frameOffset = 0;  %NEEDS TO BE CHANGED
        reconParams.nFrames=1;       %NEEDS TO BE CHANGED
        reconParams.nBins=1;        %NEEDS TO BE CHANGED
    else
        rdfFile=input('Enter rdf filename');
        rdf=readRDF(rdfFile,false);
        system(sprintf('cp %s rdf.1.1',rdfFile));
        reconParams.inputFilename = [reconParams.dir 'rdf'];
        reconParams.frameOffset = 0;  %NEEDS TO BE CHANGED
        reconParams.nFrames=1;       %NEEDS TO BE CHANGED
        reconParams.nBins=1;        %NEEDS TO BE CHANGED
    end
end

% Check reconParams for consistency, default settings etc
[reconParams, keyholeParams, scanner, acqParams] = checkReconParamsConfig(reconParams, rdf);

%Run FTR outlier detection algorithm for supported scanners
if isfield(scanner,'radialDevicesPerUnit') && isfield(reconParams,'FTR') && reconParams.FTR
    reconParams = identifyFTRUnits(reconParams, scanner);
end

%% Generate data corrections (based on flags in reconParams)
%if (reconParams.genCorrectionsFlag)
reconParams = petCorrections(reconParams, scanner, acqParams);
%end

%% READ well counter calibration file and generate multiplicative matrix
if isfield(reconParams,'wcc3dFilename') && exist(reconParams.wcc3dFilename,'file')
    wccfileinfo=dir(reconParams.wcc3dFilename);
    wccsens=readRaw(reconParams.wcc3dFilename,[1,1,acqParams.nZ],'float','l',0);
    wccact=readRaw(reconParams.wcc3dFilename,[1,1],'float','l',wccfileinfo.bytes-4);
else
    wccsens=ones(1,1,acqParams.nZ);
    wccact=1;
    disp('WARNING: No well counter correction! This will affect quantitation.');
end
wccsensmat=repmat(wccsens,[reconParams.nx,reconParams.nx,1]);

%% Setup FTR flags
if ~isfield(reconParams,'FTR')
    reconParams.FTR = 0;
    reconParams.FTRCorr = 0;
end
if reconParams.FTR && ~isfield(reconParams,'FTRCorr')
    reconParams.FTRCorr = 1;  % turn on FTR correction by default if FTR flag is 1
end
if reconParams.FTR && ~isfield(reconParams,'FTRunits')
    error('\nError: reconParams.FTR was enabled and now requires reconParams.FTRunits field to be populated.\n');
end

%% Determine if keyhole reconstruction is required
nf=scanner.maxFOV/10.;
nx=reconParams.nx;
crossoverDFOV = ((nf*sqrt(1.0+(nf*nf)/(nx*nx))) - (2.0*sqrt(2.0)))/ (nf*(1.0 + (nf*nf)/(nx*nx)))* scanner.maxFOV/10.;
crossoverDFOV = floor(crossoverDFOV*10.0);

if (reconParams.FOV < crossoverDFOV)
    reconParams.keyholeFlag = 1;
elseif (reconParams.FOV >= crossoverDFOV) && (reconParams.FOV < scanner.maxFOV)
    reconParams.keyholeFlag = 0;
else
    reconParams.keyholeFlag = 0;
end

%% COMPUTE PSF
if reconParams.detectorResponseFlag
    reconParams = petrecon_detectorResponseParams(reconParams, scanner);
end


%% Un-scaling
pixelSizecm=(reconParams.FOV/10)/reconParams.nx;
nomPixelSize=(scanner.maxFOV/10)/128;
if isvector(strfind(reconParams.algorithm, 'TOF'))
    reconImg=reconImg/(1e6*wccact*scanner.tofWccActScaleFactor*nomPixelSize*nomPixelSize/ ...
        (pixelSizecm*acqParams.positronFraction));
else
    error('This is only for TOF!\n');
end

%% X flip of image if patientEntry is Head First
%SS Needs to be checked for PETMR
% Image flip lr and image index z flip for head first. After this the fastest changing is to the
% patient left (new 1st index), 2nd index is patient posterior, 3rd index is inferior.
% This works because this is a PET first slice in front machine
tempImg=reconImg;
if (acqParams.patientEntry == 0)
    for kBin = 1:size(reconImg,4)
        for kSl=1:size(reconImg,3)
            reconImg(:,:,kSl,kBin)=flipud(tempImg(:,:,end-(kSl-1),kBin));
        end
    end
end

%% Unstiching
nx = size(reconImg, 1);
ny = size(reconImg, 2);
nz = acqParams.nZ;
reconFrames = zeros(nx,ny,nz,reconParams.endFrame,reconParams.endBin);
for kBin = reconParams.startBin:reconParams.endBin
    for kFrame = reconParams.startFrame:reconParams.endFrame
        startZ = (kFrame-reconParams.startFrame)*(nz-reconParams.overlap)+1;
        reconFrames(:,:,:,kFrame,kBin) = ...
            reconImg(:,:,startZ:(startZ+nz-1),kBin-reconParams.startBin+1);
    end
end

%% Loop over frames and bins
for kFrame = reconParams.startFrame:reconParams.endFrame
    for kBin = reconParams.startBin:reconParams.endBin
        reconImg = reconFrames(:,:,:,kFrame,kBin);
        if sum(reconImg(:))
            % generate filenames for this frame/bin
            fileNames=generateFileExtn(reconParams, kFrame, kBin, reconParams.keyholeFlag );
            
            % pseudo-crystal padding for sinograms
            if isfield(reconParams, 'pseudoCrystalRebinFlag') && reconParams.pseudoCrystalRebinFlag
                if kFrame==1 && kBin==1
                    scannerOrig=scanner; acqParamsOrig=acqParams; %SS Nov 2013 (maybe there's a better way?)
                end
                [fileNames, acqParams, scanner] = ...
                    genPseudoCrystalSinos(fileNames, reconParams, scannerOrig, acqParamsOrig);
            end
            
            % Additional vertical (y) shift for Columbia to account for table
            % deflection between PET and CT scan FOV
            if (isvector(strfind(scanner.name, 'COLUMBIA')))
                [reconParams,acqParams] = tableShiftVQC(kFrame, reconParams, acqParams, scanner);
            end
            
            % pad image for keyhole and nonkeyhole recons (currently pads only if it is nonTOF recon)
            padImParams=padImg(reconParams, scanner);
            
            % assign FTRunits for single frame/bin to padImParams
            if reconParams.FTR
                padImParams.FTRunits = reconParams.FTRunits{kFrame,kBin};
            end
            
            %Apply slice-to-slice wcc value
            reconImg = reconImg./wccsensmat;
            
            nslice=size(reconImg,3);
            
            %Extract image
            x2=linspace(-(reconParams.nx-1)/2.0,...
                (reconParams.nx-1)/2.0,reconParams.nx).^2;
            y2=linspace(-(reconParams.nx-1)/2.0,...
                (reconParams.nx-1)/2.0,reconParams.nx)' .^2;
            
            targetMask=x2(ones(reconParams.nx,1),:)+y2(:,ones(reconParams.nx,1))...
                <= (reconParams.nx/2)^2;
            
            tempImg=zeros(reconParams.nx,reconParams.ny,nslice);
            
            cropX = padImParams.cropX;
            cropY = padImParams.cropY;
            cropXmin=max(cropX,0);
            cropYmin=max(cropY,0);
            cropXmax=min(cropX+reconParams.nx,padImParams.nx);
            cropYmax=min(cropY+reconParams.ny,padImParams.ny);
            
            reconImg = reconImg .* repmat(targetMask,[1 1 nslice]);
            tempImg(cropXmin+1:cropXmax, cropYmin+1:cropYmax,:) = ...
                reconImg(cropXmin-cropX+1:cropXmax-cropX,cropYmin-cropY+1:cropYmax-cropY,:);
            reconImg = tempImg;
            
            %% Image interpolation to reduce PET-PET misalignment in the
            %% overlap region
            if (isvector(strfind(scanner.name, 'COLUMBIA')))
                error('Not done for COLUMBIA!\n')
                %reconImg = tablePostInterpolation(kFrame, reconParams, padImParams, scanner, reconImg);
            end
            
            tofproj3d(reconImg, fileNames, padImParams, keyholeParams, acqParams, scanner);
        end
    end
end


%%
function tofproj3d(image, fileNames, reconParams, ~, acqParams, scanner)

image = single(image);

if reconParams.timeMash>1
    error('Not done for this case! In tofosem3d, lesion insertion data should be added after data mashing!\n')
end

%% Initialize variables
sigmas=3;
wtStep=0.1;
if strcmp(scanner.name,'PETMR')
    nDist = 6401;
else
    nDist = 7201;             % Changed to allow up to 1 cm VQC shift
end                         % 26 Feb 2007 cws

% thetaLimit=-1;           % 04Sep2007 cws - Commented 19-Dec-2012 twd
tofFlag=1;

%% Read emission data file and required dimensions
hdr=readRDF(fileNames.emFilenameRDFTOF);

nu=hdr.nu;
nv=hdr.nv;
nphi=hdr.nphi;
nt=hdr.nt;

if (reconParams.decayCorrFlag ~= 0)
    decayFactor = readIntermediateFile(fileNames.decayFilename);
else
    decayFactor = 1;
end

if (reconParams.durationCorrFlag ~= 0)
    durationFactor = readIntermediateFile(fileNames.durationFilename);
else
    durationFactor = 1;
end

if (reconParams.normDeadtimeCorrFlag ~= 0)
    normDeadtimeFrame=1./readIntermediateFile(fileNames.normDeadtimeFilename);
    if reconParams.durationCorrFlag == 2
        normDeadtimeFrame = normDeadtimeFrame.*durationFactor;
    end
    if reconParams.decayCorrFlag == 2
        normDeadtimeFrame = normDeadtimeFrame./decayFactor;
    end
else
    normDeadtimeFrame=ones(acqParams.nU, acqParams.nV,acqParams.nPhi,'single');
    if reconParams.durationCorrFlag == 2
        normDeadtimeFrame = normDeadtimeFrame.*durationFactor;
    end
    if reconParams.decayCorrFlag == 2
        normDeadtimeFrame = normDeadtimeFrame./decayFactor;
    end
end

%%  Set up timing
if (strcmp(scanner.name,'DXR') || strcmp(scanner.name,'DXT'))
    % The 89.25 value below is very slightly different from the header
    % value of 89.2459. This special hard-code could be removed, but
    % auto-test would need to be re-run.
    tLSB = 89.25;
else
    tLSB= acqParams.dT;  % This is the time-mashed delta T.
end

%% Set up the subset list
subsetList=genOsemIndex(reconParams.numSubsets,nphi);
viewsPerSubset=nphi/reconParams.numSubsets;
nBlocks=scanner.numBlocksPerRing; %scanner.numUnitsPerRing;
nXtals=scanner.radialCrystalsPerBlock; %scanner.radialCrystalsPerUnit;
blkSize=scanner.radBlockSize;
ringDiameter=scanner.effectiveRingDiameter;

% calculate the view angles for each subset
numSubsets = reconParams.numSubsets;
% default: use evenly distributed angles for subsets
if ~isfield(reconParams, 'subsetSelectionScheme')
    reconParams.subsetSelectionScheme = 'distributed';
    reconParams.subsetAngleOffset = 0;
end
subsetTable=zeros(viewsPerSubset, numSubsets, 'uint32');
if strcmpi(reconParams.subsetSelectionScheme, 'contiguous')
    fprintf('\n Using contiguous angle subset scheme ...\n\n');
    subsetTable(:) = 0:viewsPerSubset*numSubsets-1;
else
    angleOffset = reconParams.subsetAngleOffset;
    fprintf('\n Using distributed angle subset scheme with angle offset=%d ...\n\n', angleOffset);
    for sb = 0:numSubsets-1
        for viewIdx = 0:viewsPerSubset-1
            sectionIdx = mod(sb+angleOffset*viewIdx, numSubsets);
            subsetTable(viewIdx+1, sb+1)=viewIdx*numSubsets+sectionIdx;
        end
    end
end

%% Create boundary array for NP projector
alpha=atan((blkSize/nXtals)/(ringDiameter/2));
radCoords = sinogramRadCoords(nu,nXtals,...
    alpha,2*pi/nBlocks-alpha*nXtals,ringDiameter);

%% Process timing mash information (see 2007 book 1, p21)
tLSBProc=reconParams.timeMash*acqParams.dT;
pFactor=floor(((nt-1)/2-floor(reconParams.timeMash/2))/reconParams.timeMash);
numTProc=2*pFactor+1;
firstBinMash=(nt-1)/2-floor((reconParams.timeMash-1)/2)-pFactor*reconParams.timeMash+1;
lastBinMash=firstBinMash+numTProc*reconParams.timeMash-1;
if mod(reconParams.timeMash,2)
    TOFoffset=0;
else
    TOFoffset=0.5*tLSB;
end

%% Create TOF weights array
if reconParams.timeMash==nt
    tofWeights=ones(1,nDist,'single');
else
    %  tofWeights=initTOFWeights(numTProc,nDist,reconParams.tRes,tLSBProc,...
    %     wtStep,sigmas,TOFoffset);
    tofWeights=initTOFWeights(numTProc,nDist,sqrt(scanner.tRes^2+tLSBProc^2),tLSBProc,...
        wtStep,sigmas,TOFoffset);  % MT 24-FEB-2012
end

reconNx=reconParams.nx;

%%
if reconParams.FTR && ~isempty(reconParams.FTRunits)
    fprintf('Fault Tolerant Reconstruction detected. Affected units are:');
    for m = 1:length(reconParams.FTRunits)
        fprintf(' %d',reconParams.FTRunits(m));
    end
    fprintf('\n');
    FTRmask = createFTRmask(reconParams.FTRunits,scanner,acqParams);
    if reconParams.FTRCorr
        fprintf('Setting affected LOR values to zero in both emissions and normalization sinograms.\n');
        normDeadtimeFrame = normDeadtimeFrame .* FTRmask;
    else
        fprintf('Setting affected LOR to zero in emission sinogram only. No FTR compensation.\n');
    end
    FTRflag = 1;
else
    FTRflag = 0;
end

%% Create normalization images (backprojection of acf)
if (reconParams.detectorResponseFlag)  %changes for angle-dependent PSF   MT 01/24/2013
    %Make copy for normImage calculation. Need original normdeadCorr later.
    normdeadCorrForNormImage=normDeadtimeFrame;
    %fill detResponseConvMtx
    load(reconParams.detectorResponseFile);
    if (reconParams.detectorResponseFlag==1)
        normdeadCorrForNormImage=detResponseConvMtx'* ...
            reshape(normdeadCorrForNormImage,nu,nv*nphi);
        normdeadCorrForNormImage=reshape( ...
            normdeadCorrForNormImage,acqParams.nU,acqParams.nV,acqParams.nPhi);
    elseif  (reconParams.detectorResponseFlag==2) %changes for angle-dependent PSF   MT 01/24/2013
        for ang = 1:acqParams.nPhi
            k = rem(ang,scanner.radialCrystalsPerUnit);
            if (k == 0)
                k = scanner.radialCrystalsPerUnit;
            end
            normdeadCorrForNormImage(:,:,ang) = squeeze(detResponseConvMtx(:,:,k))'*squeeze(normdeadCorrForNormImage(:,:,ang));
        end
    end
    if reconParams.detectorResponseAxialFlag
        normdeadCorrForNormImage=smoothAxialPlanes(normdeadCorrForNormImage, ...
            acqParams,reconParams.detectorResponseAxialFactor);
    end
    if reconParams.acfCorrFlag   %added check if acfCorrFlag is true before reading acf file  MT 27SEP2013
        acfCorr=readIntermediateFile(fileNames.acfFilename);
    else
        acfCorr=ones(acqParams.nU, acqParams.nV,acqParams.nPhi,'single');
    end
    multCorr=normdeadCorrForNormImage.*acfCorr;
    clear normdeadCorrForNormImage;
else
    if reconParams.acfCorrFlag
        acfCorr=readIntermediateFile(fileNames.acfFilename);
        multCorr=normDeadtimeFrame.*acfCorr;
    else
        multCorr=normDeadtimeFrame;
    end
end

%% Iterative loop
for subset=1:reconParams.numSubsets
    for angle=0:viewsPerSubset-1
        thisView = subsetTable(angle+1, subsetList(subset)+1);
        
        reconParams.subsetAngles=int16(thisView);
        %         proj = squeeze(callProjector(image, ...
        %             reconParams, scanner, acqParams, 'forward',...
        %             tofFlag, numTProc, nDist, wtStep, tofWeights));
        
        proj = squeeze(FDD( image,...
            acqParams.mode, ...
            acqParams.nU, ...
            acqParams.nV, ...
            acqParams.nPhi, ...
            acqParams.sU, ...
            acqParams.sV, ...
            reconParams.nx, ...
            acqParams.nZ, ...
            reconParams.FOV/double(reconParams.nx), ...
            acqParams.sV, ...
            reconParams.radialRepositionFlag, ...
            scanner.effectiveRingDiameter, ...
            scanner.numBlocksPerRing, ...
            scanner.radialCrystalsPerBlock, ...
            scanner.radBlockSize, ...
            reconParams.subsetAngles, ...
            acqParams.nPhi, ...
            reconParams.xOffset, ...
            reconParams.yOffset, ...
            reconParams.rotate, ...
            tofFlag, ...
            numTProc, ...
            nDist, ...
            wtStep, ...
            tofWeights));
        
        if reconParams.detectorResponseFlag
            acfPlane = acfCorr(:,:,thisView+1);
            normdeadPlane = normDeadtimeFrame(:,:,thisView+1);
        else
            multPlane = multCorr(:,:,thisView+1);
        end
        if (reconParams.detectorResponseFlag == 2)    %changes for angle-dependent PSF   MT 01/24/2013
            k = rem(thisView+1,scanner.radialCrystalsPerUnit);
            if (k == 0)
                k = scanner.radialCrystalsPerUnit;
            end
        end
        
        for tstep=1:numTProc
            if reconParams.detectorResponseFlag  %changes for angle-dependent PSF   MT 01/24/2013
                if (reconParams.detectorResponseFlag == 1)
                    projtemp=detResponseConvMtx*(proj(:,:,tstep).*acfPlane);
                elseif (reconParams.detectorResponseFlag == 2)
                    projtemp=squeeze(detResponseConvMtx(:,:,k))*(proj(:,:,tstep).*acfPlane);
                end
                if reconParams.detectorResponseAxialFlag
                    projtemp=smoothAxialPlanes(projtemp,acqParams, ...
                        reconParams.detectorResponseAxialFactor);
                end
                proj(:,:,tstep)=projtemp.*normdeadPlane;
            else
                proj(:,:,tstep)=proj(:,:,tstep) .* multPlane;
            end
        end
        
        % If time mashing was used in the acquisition, and the mashing
        % factor did not evenly divide the coincidence window width,
        % then the first and last time bins were "short" one or more
        % LSB's.  This is described by the timeMashFristBinDiscount;
        % if there is a time mashing discount, apply it here (Note
        % that the discount applies to all elements of the forward
        % model, so this is the right place to do it).
        if acqParams.tMashFirstBinDiscount > 0
            proj(:,:,1)=proj(:,:,1)*(1-acqParams.tMashFirstBinDiscount);
            proj(:,:,numTProc)=proj(:,:,numTProc)*(1-acqParams.tMashFirstBinDiscount);
        end
        
        %The following lesion insertion logic is used only when inserting lesions into TOF projection data
        if isfield(reconParams,'lesionInsertionTOFFlag')
            if FTRflag
                FTRmaskView = repmat(FTRmask(:,:,thisView+1),[1 1 numTProc]);
                proj = proj.*FTRmaskView;
            end
            
            projLI = permute(proj,[2,3,1]);
            projLI = poisson(projLI);
            projLI = uint8(projLI);
            
            if ~exist(fileNames.lesionTOFprojFilename, 'dir') 
                system(sprintf('mkdir %s',fileNames.lesionTOFprojFilename));
            end
            
            if ~exist([reconParams.dir fileNames.lesionTOFprojFilename])
                system(sprintf('mkdir %s',fileNames.lesionTOFprojFilename));
                warning('Hanif lesionInsertionFix')
            end
            
%             disp('--------------------') 
% 
%             disp('Check Hanif Edit ^^^') 
%            
%             disp('--------------------') 
            
            currentRawFile =  [fileNames.lesionTOFprojFilename '/lesionProj.' num2str(subset) '.' num2str(angle)];
            writeRaw(currentRawFile,projLI,'uint8','l',0);
            %projLI = single(readRaw(currentRawFile, [acqParams.nV, acqParams.nT, acqParams.nU], 'uint8', 'l', 0));
        end
        
        %         if reconParams.timeMash>1
        %             mashData=data(:,:,firstBinMash:reconParams.timeMash:lastBinMash);
        %             for tmi=2:reconParams.timeMash %for tmi=2:timeMash  % MT 17-FEB-2012
        %                 mashData=mashData+...
        %                     data(:,:,firstBinMash+tmi-1:reconParams.timeMash:lastBinMash);
        %             end
        %             data=mashData;
        %         end
    end
end

function data = poisson(xm)
%function data = poisson(xm)
%	generate poisson random vector with mean xm.
%	for small, use poisson1.m
%	for large, use poisson2.m
%	see num. rec. C, P. 222

data	= xm;
xm	= xm(:);

data(  xm < 12 ) = poisson1(xm(  xm < 12 ));
data(~(xm < 12)) = poisson2(xm(~(xm < 12)));


function data = poisson1(xmean)
%function data = poisson1(xmean)
%	Generate poisson random column vector with mean xmean
%	by summing exponentials.
%	Should only be used for small values, eg < 20.

dim	= size(xmean);

data	= zeros(dim);
i_do	= ones(dim);
ee	= exp(xmean);

while any(i_do(:))
    i_do	= ee >= 1;
    data(i_do) = 1 + data(i_do);
    ee	= ee .* rand(dim) .* i_do;
end

data = data - 1;

function data = poisson2(xm)
%function data = poisson2(xm)
%	Generate Poisson random column vector with mean xm.
%	Uses rejection method - good for large values.
%	See "Numerical Recipes in C", P. 222.

sx = sqrt(2.0 * xm);
lx = log(xm);
gx = xm .* lx - gammaln(1+xm);

dim = size(xm);
data = zeros(dim);
id = ones(dim);		% indices of data left to do
id = find(id);

while id
    %	disp(length(id))
    Tss = sx(id);
    Tll = lx(id);
    Tgg = gx(id);
    Txx = xm(id);
    
    tmp = pi*rand(size(id));
    yy = sin(tmp) ./ cos(tmp);
    em = Tss .* yy + Txx;
    ib = find(em < 0);
    
    while ib
        tmp = pi*rand(size(ib,1),size(ib,2)); % modified so that nrow and ncol not used
        yy(ib) = sin(tmp) ./ cos(tmp);
        em(ib) = Tss(ib) .* yy(ib) + Txx(ib);
        ib = find(em < 0);
    end
    
    em = floor(em);
    tt = 0.9 * (1+yy.*yy) .* exp(em .* Tll - gammaln(em+1) - Tgg);
    if (any(tt > 1)), error('ERROR: 0.9 factor is too large!!!!'), end
    
    ig = rand(size(id)) < tt;
    data(id(ig(:))) = em(ig);
    id = id(~ig(:));
end