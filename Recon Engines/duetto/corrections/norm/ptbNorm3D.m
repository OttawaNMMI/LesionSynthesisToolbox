% FILENAME: ptbNorm3D
%
% PURPOSE: Execute norm correction in 3D, which gets multiplied by the
%          expanded "geoCalFactors" and expanded crystal efficiencies.
%
% INPUTS:
%    xtalEffMap 
%        Crystal efficiency factors. Acceptable inputs are:
%            (nU x numRings) - One factor per xtal
%            (2*nU x numRings) - Matrix repeated twice, which is
%            the way that it is stored in the RDF. The second part of
%            the matrix is immediately deleted (never used).
%    geoCalFactors 
%        Geometrical calibration factors - either 2D or 3D. Acceptable inputs are:
%            [] - empty array if no geoCalFactors cal desired
%            (nU x numRadialUnitXtals) - "Traditional" KH-based size
%            (nU x numVth x numRadialUnitXtals) - 3D geocal ver1
%            (nU x numVth x nPhi) - 3D geocal ver2 (full)
%    nU:   Number of samples in the radial (or U) dimension of the sinogram
%    nPhi: Number of samples in the angular dimension of the sinogram
%
% OUTPUT:
%    norm: The normalization sinogram: combined expanded geoCalFactors and 
%          expanded xtal efficiencies.
%
% Copyright 2018 General Electric Company.  All rights reserved.
