% Initialize Duetto Script
% This script initialises the matlab path and compiles mex files
% if they don't exist yet).
%
% USAGE:
%   addpath ~/duetto % change this to user-specific location
%   initializeDuetto
%
%   This script can be put in MATLAB's startup.m
%      e.g ~/matlab/startup.m in Unix-type systems
%      and "My Documents/matlab/startup.m" on Windows)
%
% WARNING: To test if it needs to run compileC to generate ALL executables,
% it only checks for FDD. For compileC_IO, it only checks for GEunlisterPET.



%% Add all subdirectories
addpath(genpath(duettoToolboxLocation))
rehash

%% Checks location of duettoMracFiles
if ~exist(fullfile(duettoToolboxLocation,'..','duettoMracFiles'),'dir')
    warning([sprintf('Duetto MRAC package not found.  Default path is set to %s.\n', ...
        fullfile(duettoToolboxLocation,'..','duettoMracFiles')), ...
        'Default path may be modified in ptbUserConfg: userConfig.mracExtDir.'])
end

%% Now check if we need to compile
if ~exist(['mexFdd.' mexext],'file')
    if ~exist('compileC','file')
        if ~exist('mexFdd.c','file')
            warning(['  Maybe there is a problem with your installation, or you are running on a non-standard architecture.'], ...
                ['mexFdd.' mexext]);
        else
            % The .c file is there, but compileC is not. Strange...
            error('compileC not found');
        end
    else
        fprintf('\nRunning compileC\n');
        compileC
    end
end

%% Recompile unlister
if ~exist(['PtbUnlist.',mexext],'file')
   fprintf('\nCompiling unlister\n');
   mexUnlister
end
