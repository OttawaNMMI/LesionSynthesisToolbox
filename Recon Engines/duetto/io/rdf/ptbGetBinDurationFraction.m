% This function finds the fraction of the acquisition time in the current
% gate from an RDF header. It computes accumBinDurations/frameDuration with
% a work-around for ungated data where the current system does not fill in
% accumBinDurations.
%
% INPUTS:
%       rdf: RDF header
% OUTPUTS:
%       fraction: fraction of the acquisition time in the current gate
