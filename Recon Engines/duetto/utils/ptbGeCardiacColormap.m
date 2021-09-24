% FILENAME: ptbGeCardiacColormap
%
% PURPOSE: To approximate the GE cardiac colormap on GE viewers
%
% INPUT:
%      N:  (Optional) - The size of the colormap. If not specified, defaults to
%          the current colormap size. A recommended size is 256.
%
% OUTPUTS:
%      c:  Colormap, of size Nx3. The 2nd dimension is RGB components.
%
% EXAMPLE:
%      imagesc(myHeartImage)
%      colormap(ptbGeCardiacColormap)
%
% Copyright (c) 2020 General Electric Company. All rights reserved.
