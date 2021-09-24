% FILENAME: ptbInitParpool
% 
% PURPOSE: Open a parpool if parallel processsing toolbox exists 
%          and parallel processing is requested via userConfig.nParallelThreads.
%          If only one frame and bin, then allow underlying functions to
%          use parfor.
% 
% INPUTS:
%   nParallelThreads : From generalParams structure
% 
% OUTPUTS:
%   numWorkers       : Either 0 (if no parallel processing) or 
%                      equal to nParallelThreads
%   opened parpool
%
% Copyright 2019 General Electric Company.  All rights reserved.
