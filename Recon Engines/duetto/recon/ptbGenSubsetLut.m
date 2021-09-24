% ptbGenerateSubsets generates subset squence and subset look-up-table for a
% given subset index and view index in a subset. 
% 
% Syntax:
%   subsetLut = ptbGenerateSubsets(nSubsets, nPhi, scheme);
% Inputs:
%   nSubsets    - number of subsets
%   nPhi        - number of projection view angles
%   scheme      - subset selection scheme: 'distributed'(default) or 'contiguous'
%   angleOffset - subset angle offset
% Outputs:
%   subsetLut   - subset look up table
