% FILENAME: ptbFfbp
%
% PURPOSE: Fourier Rebinning + filtered backprojection reconstruction
%               (This funciton is implemented based on ffbp3d.m in petRecon)
%
% INPUTS
%       filenames
%       generalParams
%       reconParams: structure defining reconstruction settings
%           FORE-specific fields:
%              transaxialWindowType (default: 'none' [ramp]).
%              transWindowParam (default: Nyquist).
%              FOREfftPhi (default: 2*nphi; may greatly affect performance).
%              FOREfftu (default: smallest poser of 2 >= nu).
%       sinoParams
%       ftrParams
%       scanner
%
% OUTPUTS
%       reconImg:    Reconstructed image
%
%
% SYNTAX:
%    currentImg = ptbFfbp(~,filenames,generalParams,reconParams,sinoParams,ftrParams,~,scanner);
%
%
% NOTE: This code contains a straightforward implementation of Fourier
%   Rebinning as described in Defrise et al, Proceedings of the 1995 Fully
%   3D Reconstruction Meeting, applied in the context of the petrecon
%   reconstruction environment.  While it is believed to be a faithful,
%   correct implementation of that reconstruction method is has not been
%   designed or tested with the rigor applied to product code.  All
%   permutations of reconstruction options may not give the expected
%   results, or any results at all.
%
%
% Copyright (c) 2020 General Electric Company. All rights reserved.
% This code is only made available outside the General Electric Company
% pursuant to a signed agreement between the Company and the institution to
% which the code is made available.  This code and all derivative works
% thereof are subject to the non-disclosure terms of that agreement.
