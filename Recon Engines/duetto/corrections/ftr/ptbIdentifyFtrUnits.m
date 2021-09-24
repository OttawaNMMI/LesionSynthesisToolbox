% FILE NAME: ptbIdentifyFtrUnits.m
%
% PURPOSE:  This file detects outlier units from the RDF singles data.
%           The function will skip if the singles data have less than 
%           30 M counts. It will create a ftrUnits cell field in reconParams, 
%           which could be remain empty if no outlying units are detected
%
% INPUTS:
%       corrParams: Structure defining the reconstruction parameters.
%       scanner:    Specifies scanner ('PETMR', 'KH' for KittyHawk,
%                   'COMET' for DIQ, and 'COLUMBIA' for DMI
%
% Note: This function has only been tested for Everest (PETMR) scanners
%       If there ends up being a nAxialRing dependence, that parameter will
%       need to be added as an input.
%
% OUTPUTS:
%       corrParams: Structure defining the reconstruction parameters.
%
% SYNTAX: corrParams = ptbIdentifyFtrUnit(corrParams, 'PETMR');
%
% Copyright 2018 General Electric Company. All rights reserved.
