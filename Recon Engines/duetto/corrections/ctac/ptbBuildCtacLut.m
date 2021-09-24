% FILE NAME: ptbBuildCtacLut.m
% syntax :
%          LUTparams = ptbBuildCtacLut(CTKV,CTCON,ctacconvscalefile, %s )
%
%  This function reads in the CTAC conversion parameters
%
%   INPUTS:
%           CTKV    CT KVp, 80 100 120 140
%           CTCON   CT Contrast ==1 ; 0 non contrast
%           ctacconvscalefile  filename for ctacConvScale.cfg
%          contains Threshold, Intercept and Slope for for numseg
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
