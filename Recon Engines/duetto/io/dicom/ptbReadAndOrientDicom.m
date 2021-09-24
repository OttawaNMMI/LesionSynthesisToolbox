% FILE NAME: ptbReadAndOrientDicom
% 
% This function reads a Dicom folder and returns a "chunk" structure for
% MRAC processing.
% 
% INPUT:
%    inputDicomDir - Full path of the Dicom directory, or wild-card of files
%    zUniformSpacingFlag (optional) - Use uniform spacing specified in DCM 
%                           header in Z direction.
% 
% OUTPUTS:
% The components of the chunks struct are output:
%    data   - Image volume in patient coordinates. Axial images to be viewed as
%             imagesc(volume(:,:,sliceNum)). The coordinate order is:
%                 1st dim - Toward patient posterior
%                 2nd dim - Toward patient left
%                 3rd dim - Toward patient inferior
%    x      - X-sample points in a row vector, positive is patient left
%    y      - Y-sample points in a column vector, positive is posterior
%    z      - Z-sample points in a column vector, positive is superior posterior
%    startSliceNumber - 1             {omit if not 1st chunk}
%    endSliceNumber   - # of slices   {omit if not 1st chunk}
% 
% Copyright (c) 2017 General Electric Company. All rights reserved.
