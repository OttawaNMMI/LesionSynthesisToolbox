% FILENAME: ptbSliceCoordsFromDicomHdr
%
% PURPOSE: This function calculates the x, y, z coordinates of each pixel
%          in a DICOM image.
%
% INPUTS:
%     hdr - Either:
%               (a) Header structure from dicom info
%            OR (b) Dicom header filename
%     vectorFlag - (optional, default to false) If "true," will return vectors
%           rather than matrices. Requires x to increase in the rows and y to
%           increase in the columns.
%
% OUTPUTS:
%     xCoords - X-coordinates for each pixel
%     yCoords - Y-coordinates for each pixel
%     zCoords - Z-coordinates for each pixel
%  Note: The Z-coordinate output can be omitted if desired (for example, if
%  running on a transaxial slice image)
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
