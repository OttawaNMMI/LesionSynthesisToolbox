% ptbApplySinoSpacePsf - Apply sinogram-based PSF.
%
% Inputs:
%          projSino   - Contains a non-TOF sinogram (or single TOF bin)
%          sinoParams - Used only for the phiAngles indices, nZ, and nThets
%          psfMatrix  - Input the non-transpose version, will transpose based on
%                       the projector function.
%          psfOptions - from reconParams.corrParams. Type PtbPsfOptions.
%          projectorFunction - Must contain BDD or FDD (case insensitive). Will
%                       apply transpose for back-projection.
%
% Outputs:
%          projSino   - sino with PSF applied
%
% Copyright 2020 General Electric Company.  All rights reserved.
