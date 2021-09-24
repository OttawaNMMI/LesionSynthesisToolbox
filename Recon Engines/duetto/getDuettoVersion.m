function out = getDuettoVersion
% FILENAME: getDuettoVersion.m
%
% PURPOSE: Prints version number of Duetto or outputs it as a string
%
% INPUTS:
%    N/A
%
% OUTPUTS:
%    out:    version number as a string
%
% Copyright 2019 General Electric Company. All rights reserved.
%
% HISTORY:
%   14 Feb 2019  Duetto_v01.06.01 IQ matching for PETMR MP26 R01
%   15 May 2019  Duetto_v01.06.02 
%   14 Aug 2019  Duetto_v02.01    RDFv10 processing +PETCT DMI IQ matching
%   14 Oct 2019  Duetto_v02.03    IQ matching for PETMR MP26 R02
%   16 Dec 2019  Duetto_v02.04    Updates to RDFv10
%   12 Mar 2020  Duetto_v02.06    Updates to PSF, MRAC, includes FBP
%   29 Apr 2020  Duetto_v02.07    IQ matching for PETCT release
%   24 Nov 2020  Duetto_v02.13    IQ matching for PETCT release
% =============================================================

ver = 'duetto_v02.13_Nov2020';

if nargout > 0
    out = ver;
else
    fprintf('Running Duetto version: %s\n', ver)
end
