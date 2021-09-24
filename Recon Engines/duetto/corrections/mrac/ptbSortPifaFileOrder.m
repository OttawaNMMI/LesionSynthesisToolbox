% FILENAME: ptbSortPifaFileOrder
%
% PURPOSE: This function checks whether PIFAs' start location matches the
%          RDF's start location. This function is not required for toolbox
%          generated PIFAs, but it is required for scanner-generated PIFAs
%
% INPUTS:
%    generalParams
%    frameStats
%
% OUTPUTS:
%    reorganized PIFA files on the disk
%
% Note that the RDF# might be different from the RPDC.#.img !
% The RDF# is based on the acquisition order of the RDPC, not the frame#.
% It is the RDF# that we want to match to the PIFAs
%
% Copyright 2019 General Electric Company.  All rights reserved.
