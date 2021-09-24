% [seg Lz] = sfm_chanvese(img,mask,iterations,lambda)
%
% img - any image (2D or 3D).  color images will be
%       converted to grayscale.
%
% mask - binary image representing initialization.
%        (1's foreground, 0's background)
%
% iterations - number of iterations to run
%
% lambda - relative weighting of curve smoothness
%          (lambda will ususally be between [0,1])
%
% seg - binary map of resulting segmentation
%       (1's foreground, 0's background)
%
% Lz - A list of the indexes of points on the zero level set.
%
% --------------------------------------
% written by Shawn Lankton (4/17/2009) - www.shawnlankton.com
