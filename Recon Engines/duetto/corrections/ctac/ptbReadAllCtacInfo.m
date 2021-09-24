% FILENAME: ptbReadAllCtacInfo
%
% PURPOSE: Read DICOM header info from CT image files
%
% INPUTS:
%    ctacDir       : Directory where the CT images are
%    ctFileMask    : Typically '*CTDC*'
%    terse         : Determines print-out of some diagnostics.
%                    Set to 0 for no print-out, 3 for most.
%    readExtraInfo : optional, set to 0 or 1 defaults to 0).
%                    If 1, will store extra timing info in the structure.
%                    Mainly useful for CINE-CT.
%
% OUTPUT:
%    ctdcInfo : Structure with header info, sorted in Slice Location order
%               (and then MidScanTime if readextrainfo == 1)
%
% Copyright 2019 General Electric Company.  All rights reserved.
