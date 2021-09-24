% FILENAME: xtal2sino
%
% PURPOSE: To provide transaxial sinogram indices from crystal indices. All
%          inputs and outputs are indexed by 1 (Matlab convention).
%          Note that the order of the coordinates doesn't matter, as the
%          transaxial sinogram indexing is unaffected.
%          If the output is invalid based on the W input, then the output will
%          produce Nan values.
%          For more info: DOC1880488 - Data Mapping in GE PET Scanners
%
% INPUTS:
%      X1 : First crystal transaxial coordinate
%      X2 : Second crystal transaxial coordinate
%      N  : Number of transaxial crystals (around the ring)
%      W  : Sinogram width (in the radial "u" dimension)
%
% OUTPUTS:
%      R  :  radial sinogram coordiate (often called "u")
%      T  :  angular sinogram coordinate (phi)
%      negate : This is the F function described in "DOC1880488 - Data Mapping
%               in GE PET Scanners", which determines whether to flip V-Theta
%               index and time dimension.
%
% EXAMPLES:
%      For single LOR with PET/MR:
%          [R,T,F]=xtal2sino(93, 401, 448, 357);
%      To create R, T, & F look-up tables:
%          [R,T,F]=xtal2sino(1:448, (1:448)', 448, 357);
%
% Copyright (c) 2020 General Electric Company. All rights reserved.
