%
% FILE NAME: ptbAssignAnatomyId.m
%
% This function determines which anatomy ID is to be assigned to a particular 
% bed station number.
%
% INPUTS:
%       lavaStruct: structure containing directory info, which is sorted
%            according to bed station number (obtained from ptbSortLavaDirs.m)
%       headMRAC: 1 for head Atlas, 2 for partial head, 3 for head ZTE
% OUTPUTS:
%       lavaStruct: same as input, with addition of field lavaStruct.AnatomyID
%
% SYNTAX:
%       lavaStruct = ptbAssignAnatomyId(lavaStruct, headMrac);
