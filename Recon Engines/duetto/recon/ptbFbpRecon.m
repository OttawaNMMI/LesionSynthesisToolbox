% Filtered Back-projection Reconstruction
%
% INPUTS:
%   sinogram: radial-repositioned 2D (direct slcies) sinogram (PtbSinogram) 
%   scanner:  Structure defining the scanner geometry (PtbScanner)
%   imParams: output image parameters (PtbImage, without data)
%   window:   Apodizing window
%   fwhm:     Full Width at Half Maximum of the filter
%
% OUTPUTS:
%   reconImage: Reconstructed image 
