% This function generates a map of linear attenuation coefficients from a 
% 2D CTAC dataset through filtered back-projection
%
%   Syntax:
%       muImg = ctac2muImg(acf2d, scanner, pifa);
%       muImg = ctac2muImg(acf2d, scanner, pifa, xOffset,yOffset, rotate);
%
%   Inputs:
%       acf2d      -   An instance of PtbSinogram: acf2d = exp(-mu*x);
%       scanner    -   An instance of PtbScanner
%       pifa       -   An instance of PtbPifa 
%
%   Outputs:
%       muImg    -   3D image set of linear attenuation
%                      co-efficients at 511 KeV in units of 1/mm
%                      It's an instance of PtbImage
