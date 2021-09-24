% FILENAME: ptbPostFilter
%
% PURPOSE: Post-filter a reconstructed image
%
% INPUTS:
%   reconImg    - Image matrix
%   reconParams - Structure with the following parameters:
%                   - postFilterFwhm [mm]
%                   - zFilter (3-point fitlter, zFilter = X in [1 X 1])
%                   - radialFov [mm]
%                   - nX (optional)
%                   - verbosity (optional)
%
% OUTPUT:
%    reconImg   - Filtered input image
%
% Copyright (c) 2020 General Electric Company. All rights reserved.
