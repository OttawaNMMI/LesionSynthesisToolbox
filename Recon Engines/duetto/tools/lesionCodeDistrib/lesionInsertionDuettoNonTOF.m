% FILENAME: lesionInsertionDuettoNonTOF
%
% PURPOSE: Take synthetic lesions in image space and add them to non-TOF
% raw data for future reconstructions.
%
% INPUTS:
%   userConfig:     The parameter structure corresponding to the baseline
%                   reconstruction.
%   lesionImg:      An image of the lesion(s) to be inserted.  This should
%                   be generated using a prior ir3d.sav file (or DICOM
%                   images), corresponding to the userConfig structure
%                   input.  That prior recon is used for location and
%                   quantitation baselines.  The input image should be the
%                   lesion(s) only.
%
% OUTPUTS:
%   prompts_f*b*.lesion.sav files.
%
%	To reconstruct with the synthetic lesion, rename the files to
%       prompts_f*b*.sav (backing up the original files as desired).
%
% LIMITATIONS:
%   1. No changes are made to the attenuation map.  As such, inserting
%   lesions into locations where the attenuation would change (e.g. lung)
%   is not advised.
%
% Copyright 2019 General Electric Company.  All rights reserved.
