% FILE NAME: ptbStitchFrames (original filename: stitchFrames.m)
%
% This function 'stitches' image frames by applying overlap weighting
%
% INPUTS:
%       imgFrames: Image array (nx, ny, nz, nFrames, nBins)
%       overlap:   Number of overlap slices
%   Optional parameters for decay, duration and sensitivity corrections
%       frames:    frame index, 
%       bins:      bin index
%       scannerCalParams: instance of PtbScannerCalParams
%       frameStats: array (nBins, nFrames) of PtbFrameAcqStats
%
% OUTPUTS:
%       reconImg:   Overlap corrected image array (nx, ny, nSlices, nBins)
%
%  This funtion assumes that the following corrections have been applied to the
%  reconstructed image:
%     Decay, Duration, WCC slice to slice sensitivity (this is not the
%     triangular senstivity profile)
%  The base equation for overlap correction is:
%     C = [W2*W1*S1*D2*D1*I1 + W1*W2*S2*D1*D2*I2]/[W1*T2*S2*D1 + W2*T1*S1*D2]
%
%  Since our images have been corrected for Decay, Duration, and WCC as:
%     I1Cor=I1*W1*D1/T1, the equation for C is modified as:
%     C = [W2*S1*D2*T1*I1Cor + W1*S2*D1*T2*I2Cor]/[W1*T2*S2*D1 + W2*T1*S1*D2]
