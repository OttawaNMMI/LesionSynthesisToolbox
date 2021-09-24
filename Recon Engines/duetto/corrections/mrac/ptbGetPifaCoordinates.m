% FILE NAME: ptbGetPifaCoordinates.m
%
% This function is the wrapping function for generating the inVivo (patient or
% phantom portion) PIFA data from MR-based PCT and/or TOF-NAC images.
%
% INPUTS:
%       petStartLocation: As returned from "ptbIdentifyRawDicom"
%       patientPosition: Character string, such as HFP, FFDL, etc.
%       nZ: number of slices in PET bed position (for the PIFA)
%       sZ: PET slice interval (for the PIFA)
%       pifaFov_mm: FOV of the PIFA
%       pifaMatrix: Number of pixels in X or Y dimension of the PIFA
%
% OUTPUT:
%       xPIFA: x-coordinates of PIFA
%       yPIFA: y-coordinates of PIFA
%       zPIFA: z-coordinates of PIFA
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
