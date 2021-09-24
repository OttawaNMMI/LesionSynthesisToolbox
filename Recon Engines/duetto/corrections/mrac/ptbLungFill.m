%
% FILE NAME: ptbLungFill.m
%
% This function fills the misclassfied lungs.
% 
% INPUTS:
%      pCT: pseduCT to be processed. In patient coordinates:
%                           (increasing row index = toward posterior)
%                           (increasing col index = toward patient left)
% OUTPUTS:
%      pCTFill: pseduCT after lung filling.
% SYNTAX:
%     pCTFill = ptbLungFill(pCT)
%    
% Copyright (c) 2017 General Electric Company. All rights reserved.
