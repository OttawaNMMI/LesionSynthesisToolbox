% ptbGenSubsetSequence generates the sequence of subsets for 
% ordered subsets algorithms. The sequence contains the index of the 
% first angle for each subset. 
%
% Syntax:
%     subsetSequence = ptbGenSubsetSequence(numSubsets, nPhi)
% Inputs:
%     nSubsets  -   number of subsets (N)
%     nPhi      -   total number of angles
% Outputs:
%     subsetSequence     -   ordered sequence of subsets
% History:
%    
%   06/26/2004  Written by RMM based on product C-code and its IDL version 
%               written by Steve Ross, originally called genOsemIndex.m 
%   07/19/2004  Changed genOsemIndex to give subset indices
%               from 0 to N-1 instead of 1 to N.
%   05/21/2014  HQ fixed buffer overrun when this code is translated to C
%               code.
%   05/19/2015  HQ renamed to ptbGenSubsetSequence.m for Duetto
% ========================================================================%
