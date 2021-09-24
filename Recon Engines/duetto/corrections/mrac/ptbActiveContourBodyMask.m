% FILE NAME: ptbActiveContourBodyMask.m
%
% Active contour segmentation for body mask using sfm_chanvese.m
% (Sparse Field Method - Chan & Verse)
% References:
% 1) Chan & Vese, "Active Contours Without Edges", IEEE Trans. Image
%    Processing, vol. 10, pp.266-277, Feb. 2001
% 2) Whitaker, "A level-set approach to 3D reconstruction from range
%    data", Int. J. Computer Vision, vol. 29, no. 3, pp. 203-231, 1998.
%
% INPUTS:   img3d: smoothed tofnac 3d volume
%           MR_mask: MR-derived pseudo-CT data, resampled to match TOF-NAC
%
% OPTIONAL INPUTS:
%           clampPercentile: clamp percentile for pre-processing tofnac 3d volume
%           lambda: stiffness parameter for the chanvese code (default = 0.5)
%           iteration: number of iteration used in the chanvese code (default = 601)
%v
% OUTPUT:
%           seg3d: body mask 3d segmented volume 
%
% SYNTAX:   
%           seg3d = ptbActiveContourBodyMask(ir3d_nac, MR_mask, Rtc,FOV_PET,FOV_MR, clampPercentile);
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
