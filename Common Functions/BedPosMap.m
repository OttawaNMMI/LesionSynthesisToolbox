% Used to derive an array where the element value corresponds to the bed
% position associated with the element number. 
%
% If an element value is in the 100's (or 1xx) the value (xx) represents 
% the bed position at that point. 
%
% If an element value is in the 200's (or 2xx) the value (xx) can be used
% to derive the bed position at that point. To derive this value take the
% number xx (by dropping the leading 2) and divide this value in half.
% Round down to the nearest integer, denoted as A. Let B represent A + 1. 
% A and B represent the two bed positions responsible for that point. 
%
% Usage:    BedPosMap(spbp,nbp,os,es) 
%
%           spbp    Slices Per Bed Position 
%           nbp     Number of Bed Position 
%           os      Number of Overlaping Slices 
%           es      Expected number of Slices 
%
% Example:  size(img) = 192,192,299 WB PET GE D710 8 BedPos 47 SPBP  
% 
%           [map] = BedPosMap(47,8,11,299)
% 
% 
%   ALSO SEE: DetBedPos.m 
%
%   History:
%
%   01/19/2017  Written by Hanif Gabrani-Juma, B.Eng 
%
%==========================================================================



function [map] = BedPosMap(spbp,nbp,os,es)

spbp = 47; % # Slice Per Bed Position (SPBP) 
nbp = 8; 
os = 11; 
es = 299; 

a = 1; % Starting Bed Position (not necessary) 
b = spbp; % Number of slices per bed position 
c = nbp; % Number of bed positions 
d = os; % Overlap slices 
e = es; % Expected number of slices in WB PET 

map = zeros(1,e);
for i = 1:c 
    map(a:b) = map(a:b) + (i+100)*ones(1,spbp);
    %disp([num2str(a) ':' num2str(b) ' Size: ' num2str(size(a:b,2))])
    a = b - (d-1); 
    b = a + (spbp-1);
end
end


    