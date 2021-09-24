% [ startMsecVec, endMsecVec ] = UnlistGatedTrigRej(rx)
%
% Called from UnlistGated.m to reject trigger intervals outside of min/max boundaries.
%
% Return the set of accepted trigger intervals.
%
% Only works for gated 'percent', 'sppb', and 'time' binning. Does not work for gated 'bypass' binning
% since the trigger intervals are unknown.
%
