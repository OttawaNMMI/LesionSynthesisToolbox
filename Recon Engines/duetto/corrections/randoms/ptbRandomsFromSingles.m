% FILE NAME: ptbRandomsFromSingles.m
%
% PURPOSE: Compute randoms from singles. This includes the calculation of
% adjustment factors in addition to the traditional 2*tau*S_1*S_2 formula.
%
% INPUTS:
%       generalParams - for verbosity level
%       randomsParams - for deadTimeFlag & old_dt3DIntCorrConst
%       sinoParams    - only for nU
%       frameStats    - edcatParams, deadTimeEventsData, singles, acqStats, etc
%
% INPUTS:
%       randoms       - randoms sinogram, based on randoms-from-singles
%
% Copyright 2019 General Electric Company. All rights reserved.
