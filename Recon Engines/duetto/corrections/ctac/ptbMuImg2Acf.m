% FILENAME: ptbMuImg2Acf
%
% PURPOSE: Generates the attenuation correction sinogram (CTAC or MRAC)
% from a 3D attenuation image set by forward projection.
%
% Inputs:
%     muImg       - an instance of PtbImage, the image values represents  the 
%                   linear attenuation co-efficients at 511 KeV in units of 1/mm
%     sinoParams  - an instance of PtbSinogram for the sinogram parameters
%     scanner     - an instance of PtbScanner
%     projector   - forward projection function name
%     rotate      - rotation in image space (optional)
%
% Outputs:
%     acf         - attenuation correction projection plane
%                   acf = exp(- lineIntegral(mu*x) );
%
% Copyright 2019 General Electric Company.  All rights reserved.
