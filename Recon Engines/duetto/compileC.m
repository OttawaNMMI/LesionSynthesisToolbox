% FILENAME: compileC.m
%
% PURPOSE: A routine to perform mex compilation of the MATLAB-callable C
% routines in the recon portion of the PET Toolbox.
%
% Developers who add new MATLAB-callable routines should add a line to this
% routine.
%
% Copyright (c) 2019 General Electric Company. All rights reserved.

currentdir = pwd;


%% Forward and back-projectors
cd(fileparts(which('mexFdd.c')))
mex mexBdd.c ptbProjUtils.c
mex mexFdd.c ptbProjUtils.c
mex mexBdd2.c ptbProjUtils.c
mex mexFdd2.c ptbProjUtils.c
mex mexBdd2a.c ptbProjUtils.c
mex mexFdd2a.c ptbProjUtils.c
mex mexBdd3.cpp ptbProjUtils.cpp
mex mexFdd3.cpp ptbProjUtils.cpp

if (exist('backproject2d.c','file'))
  mex backproject2d.c
end

%% Other reconstruction functions
cd(fileparts(which('mexGeRotate.c')))
mex mexGeRotate.c ge_sal.c  % needs subroutines from there...

cd(fileparts(which('mexHandInterp.c')))
mex -I.. mexHandInterp.c
mex -I.. mexHandInterp2.c

% C version of 3d scatter
cd(fileparts(which('mexSiddon3D.cpp')))
mex mexSingleScatter.cpp
mex mexSiddon3D.cpp

cd(fileparts(which('rivnDecomp.c')))
mex rivnDecomp.c
mex rivnDecomp1.c


%% Setup symbolic links to several private MATLAB functions
% Find some paths
if (exist('dicomread','file') == 2 && exist('dicomInfoSingleField', 'file'))
    pathForLink = fileparts(which('dicomInfoSingleField'));
    pathForTarget = [fileparts(which('dicomread')) filesep 'private/'];
    
    % Execute link commands:
    if (isequal(computer,'PCWIN') || isequal(computer,'PCWIN64'))
        linkcmd = 'copy ';
    else
        linkcmd = 'ln -s ';
    end
    
    % Put quotes around path in case there are spaces
    pathForTarget = ['"' pathForTarget '"'];
    pathForLink = ['"' pathForLink '"'];
    
    system([linkcmd pathForTarget 'dicomparse.' mexext ' ' pathForLink]);
end

cd(fileparts(which('sfm_chanvese_mex.cpp')))
compile_sfm_chanvese


%% Compile unlister and list tools
cd(currentdir)
mexUnlister

cd(fileparts(which('unpackList.cpp')))
mex unpackList.cpp

cd(currentdir)
