% This function filters the scatter tail scale factors
%
% INPUTS:
%       scatTailFactors:  scatter tail scale factors
%		sinoParams:         
%       mbscParams:       the following fields are used 
%                         mbscParams.tailFactorFilterType = 'smooth1w1';  
%                         mbscParams.tailFactorFilterW (for smooth1w1)
%                         mbscParams.polyfitOrder      (for polyfit)
% OUTPUTS:
%       filScatTailFactors: filtered scatter tail scale factors
%
