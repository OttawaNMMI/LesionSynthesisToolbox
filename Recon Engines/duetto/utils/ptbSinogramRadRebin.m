% FILENAME: ptbSinogramRadRebin
%
% PURPOSE: This program perfoms radial repositioning of emission sinograms
% or 3D projection planes. Implementation based on "Improved Radial
% Repositioning" C. W Stearns ASL Technical Report 92-54
%
% INPUTS:
%   sinoIn     - An instance of PtbSinogram with data component
%   scanner    - Scanner detector geometry
%   rrSamples  - Number of radial repositioned bins. This is
%                optional parameter. If not specified it is computed
%   extrapval  - Used to set y values if interp x values are outside limits.
%                Optional. It is set to a default if not specified.
%
% OUTPUTS:
%   sinoOut            - Radial repositioned sinogram
%   ngRadBinsModule_mm - Native geometry radial bin positions (mm)
%   rrRadBins_mm       - Radial repositioned radial bin positions (mm)
%
% Copyright 2019 General Electric Company. All rights reserved.
