% FILE NAME: ptbBlendChunks.m
%
% This function blends MR-based PCT "chunks" to create a 3D volume.
% A constant overlap and full volume coverage are assumed.
%
% INPUTS:
%       chunks: The "chunks" structure  (defined within MR2pseudoCTwrapper)
%
% OUTPUT:
%       volume: The blended volume
%       zVol:   Z-axis sample points of the blended volume
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
%
%  History:
%  2016-Aug-29 TD - Newly written.
