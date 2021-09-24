% UnlistGated(rx, sino)
%
%
%   Called from UnlistMain.m to create a set of gated frames (i.e. sinograms) with 
%   corresponding DICOM header files. A gated frame corresponds to one phase within
%   within the cardiac or respiratory cycle.
%
%   Inputs:
%       rx           - struct as defined in UnlistMain.m
%       sino         - uncompressed TOF or nonTOF sinogram buffer
%
% Notes:
% - gated frames always start on the first (respiratory or cardiac) trigger and end 
%   on the last (respiratory or cardiac) trigger
%
% Copyright (c) 2019 General Electric Company. All rights reserved.
%
