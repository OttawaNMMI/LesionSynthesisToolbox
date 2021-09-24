% FILENAME: mexUnlister
%
% PURPOSE: mex (compile) the PtbUnlist.cpp file
%
% We link with the version of HDF5 that is included with MATLAB. For R2014b
% and before, this was HDF5 1.8.6. For R2015a, it's HDF5 1.8.12. To MEX, we
% need the 1.8.6 header files (for < R2014b) or 1.8.12 header files (for >=
% R2015a). The header files are included in the 'unlister' directory. We
% also need to find the libraries within MATLAB's install location. After
% the MEX, we don't need to do anything else because the HDF5 libraries are
% already in MATLAB runtime path.
%
% Copyright (c) 2019 General Electric Company. All rights reserved.
