%  FILE NAME: ptbBuildMrLut.m
%
% Build LUT to convert MR to AC
%
% Syntax:
%      LUTparams = ptbBuildMrLut(MRscale,ctacconvscalefile, %s )
%
%  This function reads in the CTAC conversion parameters
%
%   INPUTS:
%       MRscale: use 2 for PETMR
%       ctacconvscalefile:  filename for ctacConvScale.cfg, contains
%                           Threshold, Intercept and Slope for for numseg
%   OUTPUTS:
%         returns LUTparams (3 , numseg)   containg
%         Threshold, Intercept and Slope for numseg
%       LUT.floor= LUTparams(1,1) ;
%       LUT.ceil =  LUTparams(1,numSeg ) ;
%       LUTlength= LUT.ceil  - LUT.floor ;
%       LUT.table=zeros(1,LUTlength,'single') loaded with LUT
%
%       CTAC factors are  per cm
%       output PIFA has attenuation per mm
%
%    USAGE: LUT = ptbBuildMrLut(2,'mracConvScale.cfg');
%
