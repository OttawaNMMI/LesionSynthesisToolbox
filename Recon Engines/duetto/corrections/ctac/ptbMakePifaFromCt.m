% FILENAME: ptbMakePifaFromCt.m
%
% PURPOSE: Makes an attenuation map in the form of a PIFA structure at slice locations
% corresponding to the PET slice locations in the order given by the PET location order by
% reading the CT images listed in ctdcInfo and using all CT images which overlap the PET
% slices
%
% INPUTS:
%   frameStats1 : PET frame stats
%   ctdcInfo    : CT filenames
%   ctacConvLut : Look-up table to convert HU to attenuation
%   fwhmTarg    : FWHM mm of ouput pifa
%   (optional)  : 'acqc' followed by ACQC axial shift in mm
%
% OUTPUTS:
%   pifa structure with  header info - see code below
%   pifa.data  contains attenuation map  128x128xnumPETslices
%
% Assume all CTs have same kV and FOV
%       LUT has already been made by buildLUT
%       dicom dictionary has been set for CT images
%
% Copyright 2020 General Electric Company.  All rights reserved.
