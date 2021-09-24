% [volume, xVec, yVec] = ptbOrientDicomImageLP(volume, xMat, yMat)
%
% FILE NAME: ptbOrientDicomImageLP.m
%
% PURPOSE: This function re-orients the dicom volume into patient
% orientation (wrt patient left and posterior) 
%
% INPUTS:
%     volume - dicom image volume
%     xMat - X-coordinates for each pixel
%     yMat - Y-coordinates for each pixel
%
% OUTPUTS:
%     volume - re-oriented dicom image volume
%     xVec - x-coordinate for each pixel
%     yVec - y-coordinate for each pixel
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
%
% History:
% Created by Tim Deller, 30-Sep-2015
