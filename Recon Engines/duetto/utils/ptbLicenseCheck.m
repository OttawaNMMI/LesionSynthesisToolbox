%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNTAX:  check = ptbLicenseCheck(licenseFile)
%
% PURPOSE: This function is for doing a Duetto license status check.
%
% INPUTS
%          licenseFile (optional): Filename of a license. The default is set to
%                                            fullfile(duettoToolboxLocation, 'Duetto_license').
%
% OUTPUT
%          checkResults (optional): license check results
%                                              checkResults >=0 : # of days before expiration
%                                              checkResults  = -1: License has expired
%                                              checkResults  = -2: The license file is not valid
%                                              checkResults  = -3: License file is not found
%
% Copyright 2020 General Electric Company.  All rights reserved.
