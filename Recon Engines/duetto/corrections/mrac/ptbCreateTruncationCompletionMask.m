% FILE NAME: ptbCreateTruncationCompletionMask.m
%
% This function is the wrapping function for generating the inVivo (patient or
% phantom portion) PIFA data from MR-based PCT and/or TOF-NAC images.
%
% INPUTS:
%       chunks: The "chunks" structure  (defined within MR2pseudoCTwrapper).
%       zPIFA: Slice locations in Z for the PIFA (I/S patient coordinates, mm)
%       NACfoldername: Folder name for the TOF NAC images
%
% OUTPUT:
%       TC - A 3D matrix of the binary truncation completion mask. This is
%             equivalent to the sample points from the TOF NAC (128x128x89).
%       xTC - The x-dimension sample points (patient coordinates) for TC.
%       yTC - The y-dimension sample points (patient coordinates) for TC.
%       zTC - The z-dimension sample points (patient coordinates) for TC.
%       zPCT - The z-dimension sample plains from the MR-based PCT.
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
