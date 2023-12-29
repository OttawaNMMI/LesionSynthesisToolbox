

% *******************************************************************************************************************
% *                                                                                                                 *
% * Copyright [2014] Ottawa Heart Institute Research Corporation.                                                   *
% * This software is confidential and may not be copied or distributed without the express written consent of the   *
% * Ottawa Heart Institute Research Corporation.                                                                    *
% *                                                                                                                 *
% *******************************************************************************************************************

function b = ibone(m)
%BONE   Gray-scale with a tinge of blue color map
%   BONE(M) returns an M-by-3 matrix containing a "bone" colormap.
%   BONE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(bone)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%  Modified from bone.m by Ran Klein 22/6/2010

if nargin < 1, m = size(get(gcf,'colormap'),1); end
b = flipud((7*gray(m) + fliplr(hot(m)))/8);
