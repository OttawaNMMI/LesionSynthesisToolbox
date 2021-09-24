%   This function generates a mask of the patient table used with the
%   Discovery ST/LS PET/CT scanners.It is based on the C implementation
%   (tableMask.c) which was used for segmented AC
%
%   syntax
%     mask = tableMask(nx,sx,tableHeight,tableWidth);
%
%   Inputs
%     nx            -   number of pixels
%     sx            -   pixelsize
%     xShift
%     yShift
%     tableHeight   -   position of table
%     tableWidth    -   table width parameter
%
%   Output
%     mask          -   mask with table shape
%
% History
% 04/12/2005      -   written by Ravi Manjeshwar
% 04/14/2005      -   Modified shape of mask to include the space
%                       directly beneath the patient able
% 2016-09-01  Hua Qian Extracted from ctac2muImg.m as an independent function 
