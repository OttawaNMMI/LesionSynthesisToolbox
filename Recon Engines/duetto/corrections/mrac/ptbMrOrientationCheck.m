% This function will correct for any R/L or A/P shift in the dicom series,
% and correct for patient orientation.
%
% INPUTS:
%       matrix_in: 3d volume
%       temp_hdr: out image header
%       numOfSlices: number of slice in out image 
% OUTPUT:
%       matrix_in: same as input, after correcting for patient orientation and
%       coordinate shifts
% EXAMPLE:
%   B=Orientation_Check(A, location);
