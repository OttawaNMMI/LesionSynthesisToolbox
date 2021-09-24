% FILE NAME: subSample1.m
%   Sub-samples a single dimension of the input data.
%
% Inputs:
%   input  - Matrix to be subsampled
%   s1     - Number of subsamples in dimension of interest
%   dim    - OPTIONAL. Dimension index. If omitted or if empty, will default
%            to the first non-singleton dimension.
%   method - OPTIONAL. If the number of subsamples does not evenly divide
%            the original number of samples, a method must be employed to
%            handle the boundaries in the subsampling process. The options are:
%                'nearest'- Round boundaries to nearest index
%                'linear' - Evenly divide the "straddled" sample between
%                           adjacent subsamples with linear weighting
%                           coefficients. Mean preserving. (DEFAULT)
%                'zeroPaddedUnweighted' - This method is for legacy code
%                           support purposes and is not recommended going
%                           forward. This method zero-pads the original
%                           matrix to reach an integer multiple of s1
%                           (splitting the extra elements between the
%                           beginning and end). Then, subsampling takes
%                           place. This is not spatially accurate. Also,
%                           because no weights are used, this negatively
%                           biases the outer subsamples.
