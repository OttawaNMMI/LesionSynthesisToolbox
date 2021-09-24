% FILE NAME: ptbMr2PseudoCt
%
% This function computes pseudo CT from input MR data (Lava Flex) for a
% single bed-position based on the Anatomy ID assignment. Output=> DICOM
% pseudo CT folder inside lava_stations
%
% INPUTS:
%       generalParams:
%       mracParams:    Structure of MRAC parameters
%       mracStruct:    Structure defining lava_flex directory structure
%       kFrame:        Station number ID
%       AnatomyID:     Used to determine segmentation parameters
%                      'H'=head, 'N'=partial head, 'L'=lungs, 'A'=abdomen,
%                      'P'=pelvis
%
% OPTIONAL INPUTS:
%       displayFlag:      1/0 (Turn on/off pseudoCT display), Default=0
%
% SYNTAX:
%       ptbMr2PseudoCt(generalParams, mracParams, mracStruct, 1, 'H');
%
% Copyright 2018 General Electric Company. All rights reserved.
