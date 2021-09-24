% 3D rigidbody transformation
% Input:
%   imgOrg: Original image to be transformed
%   Parameters: include: dx, dy and dz in unit of pixels, 
%                        alpha, beta and gamma in unit of degrees
% Output:
%   imgTransf: The transformed image results, its image size is the same as
%   the original image. The part moved out of original space is cropped,
%   and the empty space is filled with zero
