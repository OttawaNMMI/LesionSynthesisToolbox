% FILENAME: makeVthTable
%
% PURPOSE: Create a VTheta-to-crystal-row translation table. All inputs and
%          outputs are indexed by 1 (Matlab convention).
%
% INPUT:
%   rows :    Number of crystal rows in Z (24 for Discovery family)
%
% OUTPUT:
%   vthtable : Nvth-by-2 array of crystal indices corresponding to each row of
%              the projection plane set (Nvth=rows^2-(rows-1)).
%
% ADDITIONAL NOTES:
% The following guidance explains the order of the two columns, and is based on
%            DOC1880488 - Data Mapping in GE PET Scanners
% - The "high" crystal is the one with the greater transaxial (around
%   the ring) crystal index. Similarly, the "low" crystal is the one with the
%   smaller transaxial crystal index.
% - The "F" function is defined in DOC1880488, and is an output from xtal2sino.
%
% If F = 1, which is the more common case:
%      The columns are ordered "low" for 1st column and "high" for 2nd column.
% If F = -1, which is the less common case:
%      The columns are ordered "high" for 1st column and "low" for 2nd column.
%
% The second output, vthLUT, is entered with (Lo, Hi) and returns the index
% This inverse formulation is sometimes more convenient
% 
% Copyright (c) 2005-2020 General Electric Company. All rights reserved.
