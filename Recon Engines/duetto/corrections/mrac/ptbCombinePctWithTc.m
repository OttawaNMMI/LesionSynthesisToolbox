% FILE NAME: ptbCombinePctWithTc.m
%
% This function processes MR-based PCT "chunks" as well as the truncation
% completions mask (128x128x89) to create a combined set of truncation-completed
% chunks.
%
% INPUTS:
%       chunks: The "chunks" structure  (defined within MR2pseudoCTwrapper).
%       zPCT - The z-dimension sample plains from the MR-based PCT.
%       TC_mask - Binary truncation completion mask.
%       xTC - The x-dimension sample points (patient coordinates) for TC.
%       yTC - The y-dimension sample points (patient coordinates) for TC.
%       zTC - The z-dimension sample points (patient coordinates) for TC.
%
% OUTPUT:
%       chunks: The "chunks" structure, updated with truncation completion info.
%               The output "chunks" is a larger matrix size because it has
%               been extended with the TC info.
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
