% FILE NAME: ptbGenerateIvvPifaData.m
%
% This function is the wrapping function for generating the inVivo (patient or
% phantom portion) PIFA data from MR-based PCT and/or TOF-NAC images.
%
% INPUTS:
%       chunksOrPctDir: The first input can be either a "chunks" structure
%           (defined within MR2pseudoCTwrapper) or the folder name of a
%           single-chunk set of PCT Dicom images.
%       petStartLocation: As returned from "identifyRawDicom"
%       patientPosition: Character string, such as HFP, FFDL, etc.
%       nZ_PET: number of slices in PET bed position (for the PIFA)
%       sZ_PET_mm: PET slice interval (for the PIFA)
%       pifaFov_mm: FOV of the PIFA
%       pifaMatrix: Number of pixels in X or Y dimension of the PIFA
%       gaussianFilterFWHM_mm: Filter FWHM to apply to the PIFA
%       cradleHeight: Vertical distance from isocenter to the top of the cradle,
%           including a buffer
%       lungFillFlag: Will apply "lung fill" processing if "true," which is
%           recommended when the lungs will be off-center.
%       tcFlag: Flag for truncation completion
%       TOF_NAC_dir: Folder name for the TOF NAC images (with TC only)
%       generalParams
%
% OUTPUT:
%       ivvPifaData: A 3D matrix of ivvPifaData in scanner coordinates, ready to
%           be written as the data portion of the IVV PIFA.
%
% Copyright 2018 General Electric Company.  All rights reserved.
