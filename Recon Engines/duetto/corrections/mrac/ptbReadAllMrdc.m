% FILENAME: ptbReadAllMrdc
% 
% PURPOSE: Read DICOM header info from MR image files
%
% INPUTS
%    mracDir: Directory where the MR images are
%    mrMask:  Typically '*MRDC*'
%    terse:   Determines print-out of some diagnostics;
%             set to 0 for no print-out, 3 for most
%    readGEinfo: optional argument, set to 0 or 1
%                value (defaults to 0). If 1, will store extra MR info
%
% OUTPUT
%    MRDS: structure with header info, sorted in Slice Location order
%
% Copyright 2019 General Electric Company.  All rights reserved.
