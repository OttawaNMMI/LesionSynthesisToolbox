% [pdd] = ListPddGetOneSample(listFilePath, sampleSec)
%
% Get list file Periodic Detector Data (PDD) for one sample specified by sampleSec.
%
% Inputs:
% - listFilePath - string
% - sampleSec    - integer sample second (327 implies 'sample327')
%
% Output is a single PDD struct sample that contains contains the following:
%   pdd.singles 
%   pdd.blockBusyRatio
%   pdd.coinFovReject
%   pdd.coinInFovCount
%   pdd.coinPropLoss
%   pdd.singlesPropLoss
%   pdd.singlesHistoLoss
%   pdd.coinSorterInputCount
%   pdd.coinSorterOverrunLoss
%   pdd.singlesEnergyReject
%   pdd.singlesTdcReject
%   pdd.singlesXmitCount
%   pdd.singlesXmitLoss
%   pdd.blockMuxLossRatio
%
% 
% Copyright (c) 2019 General Electric Company. All rights reserved.
%
