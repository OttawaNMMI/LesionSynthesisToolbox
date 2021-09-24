% FILENAME: ptbFindOrientation
%
% PURPOSE: This function is to find the axial orientation of a 
%          NEMA or ACR phantom PET 3D image
%
% INPUT:
%   dirPET: the NEMA or ACR phantom PET data folder
%
% OUTPUT:
%   flagOrientation = 
%         1: The same orientation as defined in phantom template
%         0: The opposite orientation to the phantom template
%        -1: improper input data
%
% EXAMPLE: 
%           dirPET = '/localdata/Process/PhantomAC/TestData/NEMA';
%           flagOrientation = findOrientation(dirPET);
% 
% Copyright 2019 General Electric Company.  All rights reserved.
