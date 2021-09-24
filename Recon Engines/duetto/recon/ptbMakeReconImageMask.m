% ptbMakeReconImageMask
%
% Make a disk image (or cylinder) as recon image mask (or initial image).
% For an image volume initialization, make sure to pass in 3rd argument for
% class type, probably 'single'.
%
% Inputs:
%       nx        - transaxial number of pixels (for both X and Y)
%       nz        - axial number of pixels, can be 1 if only disk desired
%       className - name of the class for output (optional)
%                        default = 'logical'
%                        example = 'single'
%
% Output:
%       imageMask - 3D volume
%
% Copyright 2019 General Electric Company.  All rights reserved.
