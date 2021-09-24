% =================================================%
%  vIndex2z1z2LUT.m
%
%  This program maps the axial crystals Z1 and Z2 that contribute
%  to axial plane co-ordinates V
%
%  Syntax:  
%       v2z1z2LUT = vIndex2z1z2LUT(scanner);
%   
%   Inputs:
%       scanner   -   scanner detector geometry
%
%   Outputs:
%       v2z1z2LUT   -   A lookup table of [numProjPlanes, 2]
%                       The first column has the Z1 crystal index and the
%                       second column has the Z2 crystal index
%=================================================%
%numXtalRings = scanner.numAxialBlockRings*scanner.numAxialBlockXtals;
