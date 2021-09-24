%      [vLUT] = z1z2vIndexLUT(nZ)
%
% Compute a LUT that maps axial crystals to the projection plane row
% coordinate Vtheta.
%
% Input:
%       nZ   -   number of detector rings
%
% Output:
%       vLUT   -   A lookup table of dimension [nZ,nZ]
%
% Notes
%    1. The two input crystals to the output table (Z1,Z2) correspond to
%       the "high" and "low" (or "big" and "little") axial crystal
%       index over most of the data set.  Note that this is the reverse
%       of the output of makeVthTable.m, whose two columns of output
%       correspond to the"little" and "big" crystal index, respectively.
%    2. The input and output values are suitable for MATLAB computations,
%       meaning that the input crystal values are numbered from 1 through 
%       "rows", and the table values are numbered beginning from 1.
%
% See "GE PET Image and Sinogram Coordinates" report for more details on
% the crystal translation algorithm.
