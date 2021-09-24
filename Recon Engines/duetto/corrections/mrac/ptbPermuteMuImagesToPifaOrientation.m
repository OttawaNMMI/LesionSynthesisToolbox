% FILE NAME: ptbPermuteMuImagesToPifaOrientation.m
%
% INPUTS:
%    imVol (orientation info below)
%    patientPosition
%
% OUTPUT:
%    imVol (orientation info below)
%
% ORIENTATION INFO:
%
% Input orientation:
%    1st dimension is toward patient posterior
%    2nd dimension is toward patient left
%    3rd dimension increases into the bore. This should already be correct, from
%           the 3D interpolation into PIFA coordinates.
%
% Output orientation:
%    1st dimension is to the viewer's right, when the viewer is at the table
%           side looking into the scanner.
%    2nd dimension is toward the ground (with gravity)
%    3rd dimension is unchaged (increasing into the bore)
%
% Output orientation examples:
%    For Head-First Supine:
%      Increasing 1st Dimension: Toward patient left
%      Increasing 2nd Dimension: Toward patient posterior
%      Increasing 3rd Dimension: Toward patient superior
%    For Feet-First Supine:
%      Increasing 1st Dimension: Toward patient right
%      Increasing 2nd Dimension: Toward patient posterior
%      Increasing 3rd Dimension: Toward patient inferior
%
% Copyright (c) 2017 General Electric Company. All rights reserved.
