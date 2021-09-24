function reconImageFrames = ptbMultiFrameParRecon(initialImgFrames, ...
    filenames, generalParams, reconParams, sinoParams, ftrParams, ...
    scanner, keyholeParams, nBins, nFrames, kLevel, varargin)
% FILENAME: ptbMultiFrameParRecon.m
%
% PURPOSE: Function to reconstruct on parallel cores using MATLAB parfor
%    reconstruction.  Recon algorithm is originally defined in userConfig.
%    Only run parpool if  the license exists, multiple frames/bins,
%    and user says OK by setting generalParams.nParallelThreads > 0.
%
% INPUTS:
%    initialImgFrames
%    fileNames
%    generalParams
%    reconParams
%    sinoParams
%    keyholeParams
%    scanner
%    nBins
%    nFrames
%    kLevel
%
% OUTPUTS:
%    reconImageFrames(nX,nY,nZ,nFrames,nBins)
%
% Copyright (c) 2019 General Electric Company. All rights reserved.


% Total number of recons to do
nTotal  = nFrames*nBins;

% Initialize output image matrix
nX = reconParams.nX;
nZ = reconParams.nZ;
reconImageFrames = zeros(nX,nX,nZ,nFrames,nBins,'single');

% Kick off recons for all frames and bins
[binMatInds,frameMatInds] = meshgrid(1:nBins, 1:nFrames);
numWorkers = ptbInitParpool(generalParams.nParallelThreads);
parfor (k = 1:nTotal, numWorkers * (nTotal>1))
    jj = frameMatInds(k);
    ii = binMatInds(k);
    
    parReconParams = reconParams(ii,jj).setReconLevel(kLevel);
    initialImg = squeeze(initialImgFrames(:,:,:,jj,ii));
    
    currentImage = ptbImageRecon(initialImg, ...
        filenames(ii,jj), generalParams, parReconParams, ...
        sinoParams, ftrParams, squeeze(ftrParams.ftrMask(:,:,:,jj,ii)), ...
        scanner, keyholeParams);
    
    reconImageFrames(:,:,:,k) = currentImage;
end
