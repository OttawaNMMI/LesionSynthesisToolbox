% Filter the sinogram projections axially.
%
% INPUTS:
%     proj:  
%         3D sinogram
%     sinoParams:  
%         parameters describe sinogram.
%     kernel:  Three options:
%        Option 1: (If scalar) central weight of a center-weighted 3 point
%           averager. (For example 4 would provide a [1/6, 4/6, 1/6] kernel)
%        Option 2: (If vector) Full convolution by a kernel of any odd 
%           length. For example: [1/14, 3/14, 6/14, 3/14, 1/14]
%        Option 3: (Not passed) This will default to [1/6, 4/6, 1/6]
% OUTPUTS:
%     proj:  3D filtered sinogram, in-place, output override input.
