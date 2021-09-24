
% Function to upsample downsampled TOF scatter sinogram
% Inputs
%   scanner:   name of the scanner
%   scatFile:  scatter sinogram filename
%   normFile:  scatter normalization filename
%   mbscFile:  model-based scatter correction parameters filename
%   views:     the index/indices of desired view(s) (optional, default 1:16)
%   timeBins:  the index/indices of time bin(s)     (optional, default 1:27)
%
% Output
%   scatTotalSino:  upsampling TOF scatter sinogram with dimensions of
%                   radial bins (nU), nSlices (nV), nViews, nTimeBins
%
% Example
%   upSampTofSino = ptbUpSampleTofScatterSinogram('petmr', ...
%                   'dsTOFscatterUpPhi.tof.1.1.sav', 'scatternorm.1.1.sav', ....
%                   'mbscParamsTof_f1b1.mat', 1:16:224, 1:27);
%
% History
%   2017-09-20  Kristen Wangerin & Tim Deller
