% FILENAME: ptbSetReconXYOffset
%
% PURPOSE: Find xOffset yOffset and rotate from l/pTarget and Vqc parameters
%          lTarget and pTarget are in the patient coordinate system.
%          This function translates these to the scanner coordinate system.
%          Default lTarget and pTarget are zero.
%
% INPUTS:
%   reconParams: Structure with parameters for the reconstruction.
%   rdf:         RDF header (used for VQC and patient orientation)
%
% OUTPUT:
%   reconParams: Structure with additional (or updated) fields: xOffset, yOffset, rotate
%
% NOTES: This function only uses the following fields lTarget, pTarget.
%        If these are not present, this function checks xTarget, yTarget
%        for historical reasons.
%
% Copyright 2019 General Electric Company.  All rights reserved.
