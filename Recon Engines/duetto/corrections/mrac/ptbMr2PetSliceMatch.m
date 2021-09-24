%
% FILE NAME: MR2PT_SliceMatch.m
%
% This function creates a pseudoCT series with slice locations matched to PET
%
% INPUTS:
%       petSliceLoc: PET image slice locations
%       pseudoCtHdr: pseudoCT DICOM info
%       pseudoCtImg: pseudoCT image
%       pseudoCtLoc: pseducoCT slice locations.
%       petDFov:     max PET FOV in mm
%       verbosity:   user set screen print out verbosity
% OUTPUTS:
%       mracImg: slice-matched pseudoCT 3d volume for AC
% SYNTAX:
%     mracImg = ptbMr2PetSliceMatch2(petSliceLoc, pseudoCtHdr, ...
%                     pseudoCtImg, pseudoCtLoc, petDFov, verbosity);
%  Note, if there are no overlapping MR slices at the ends of the axial FOV
%  they will be replicated from the nearest MR image slice
