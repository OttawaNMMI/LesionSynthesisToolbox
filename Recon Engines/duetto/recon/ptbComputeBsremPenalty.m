% This function computes the gradient of the 3D potential function. 
% The potential functions currently implemented are
%     1) Quadratic
%     2) LogCosh
%     3) Huber
%     4) Generalized Gaussian
%     5) RDP
% Syntax:
%     penalty = computePenalty(inImg, priorType, priorParam)
% Inputs:
%     inImg       -   input image volume
%     priorType   -   string with prior type:
%                               'quadratic'
%                               'logCosh'
%                               'huber'
%                               'generalizedGaussian'
%                               'rdp'
%     priorParam  -   parameters required by the potential functions.
%                           Only huber and generalizedGaussian need this
% Outputs:
%     penalty   -   penalty image volume
