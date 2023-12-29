function g = redwhiteblue(m)
%REDWHITEBLUE   Linear red-white-blue color map
%   REDWHITEBLUE(M) returns an M-by-3 matrix containing a red-white-blue colormap.
%   REDWHITEBLUE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(redwhiteblue)
%
%   See also HSV, HOT, COOL, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

m2 = (m-1)/2;
increments = 1/m2;
g = (0:m2)'/max(m2,1);

g = [ones(size(g)), g,         g;...
	 flip(g),        flip(g), ones(size(g))];