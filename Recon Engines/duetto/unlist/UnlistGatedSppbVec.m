% [ startMsecVec, endMsecVec ] = UnlistGatedSppbVec(rx)
%
% Called from UnlistGated.m to support Single Phase Percent Binning (SPPB).
% SPPB is a special case of percent binning where only one phase
% is specified using the two parameter described below:
%
% rx.gatedBinVec(1) - single phase offset percent
% rx.gatedBinVec(2) - single phase width percent
%
% Refer to 'help UnlistMain' for a description of 'rx'.
%
