% FILENAME: lesionInsertionDuettoTOF
%
% PURPOSE: Take synthetic lesion(s) in image space and add them to non-TOF
% raw data for future reconstructions.
%
% INPUTS:
%   userConfig:     The parameter structure corresponding to the baseline
%                   reconstruction.
%   lesionImg:      An image of the lesion(s) to be inserted.  This should
%                   be generated using a prior ir3d.sav file, corresponding
%                   to the userConfig structure input.  That prior recon is
%                   used for location and quantitation baselines.  The
%                   input image should be the lesion(s) only.
%   flagMatOutput:  A flag to switch between *.mat and HDF5 outputs
%     (optional)            (the default is set to 1 for *.mat outputs)
%
%    outFnHDF5   : This is a nBins x nFrames cell array containing HDF5 filenames. 
%     (optional)   The sinograms in those files would be updated after insertion.
%
%
% OUTPUTS:
%   tofPrompts_f*b*.lesion.mat files or modified HDF5 files if flagMatOutput == 0
%
%	To reconstruct with the synthetic lesion, rename the files to
%       tofPrompts_f*b*.mat (backing up the original files as desired).
%
% LIMITATIONS:
%   1. No changes are made to the attenuation map.  As such, inserting
%   lesions into locations where the attenuation would change (e.g. lung)
%   is not advised.
%   2. At present, this only works for single-fame, single-bin data.
%
% Copyright 2019 General Electric Company.  All rights reserved.
