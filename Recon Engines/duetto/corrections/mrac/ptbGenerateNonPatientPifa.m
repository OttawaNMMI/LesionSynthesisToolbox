% FILENAME: ptbGenerateNonPatientPifa
%
% PURPOSE: This function generates non-patient (NP) PIFA data (without PIFA header)
% for the non-patient objects (NPO) in a PET/MR scan given the NPO
% information, including the path & file name of the PIFA templates.
%
% INPUTS:
%   generalParams
%   mracParams
%   mracStruct
%   frameStats1
%   kFrame
%
% OUTPUT:
%   nonPatientPifaData: sum of all the coil attenation maps
%
% SYNTAX:
%   ptbGenerateNonPatientPifa(generalParams, mracParams, frameStats1, kFrame, isPhantom)
%   ptbGenerateNonPatientPifa(generalParams, mracParams, sinoParams, ...
%               scanner, frameStats1, petRawDicomHdr, RPDCinfo, kFrame)
%
% Copyright 2020 General Electric Company.  All rights reserved.
