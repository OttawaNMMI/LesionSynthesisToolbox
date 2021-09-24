% Run a number of test cases for unlisting
clear; clc

% Set path
restoredefaultpath
addpath(genpath('~/duetto'))

% Path to list data; directory must also include RPDC.1.img file
workPath = '/data/LIST';
cd(workPath)
listFilePath = fullfile(workPath,'LIST0000.BLF');


%% Unlisting examples

% nonTOF static, specify list dir pathname
clear rx
rx.listFilePath = listFilePath;
rx.unlistDirPath = fullfile(workPath,'myUnlistingDir');
rx.tofMode = 'nontof';        % Options: nontof tof
rx.unlistType = 'static';  % Options: static, dynamic, gated
rx.startMsecVec = 0;         % beginning of exam
rx.endMsecVec   = 300 * 1000; % 5 minutes in [ms]
data = UnlistMain(rx);


% TOF dynamic
clear rx
rx.listFilePath = listFilePath;
rx.tofMode = 'tof';         % Options: nontof tof
rx.unlistType = 'dynamic';  % Options: static, dynamic, gated
% 4 frames totally up to a 5 minute scan
rx.startMsecVec = [0;   0.5; 1.5; 3] * 60 * 1000;  
rx.endMsecVec   = [0.5; 1.5;   3; 5] * 60 * 1000;
data = UnlistMain(rx);


% TOF gated
clear rx
rx.listFilePath = listFilePath;
rx.tofMode = 'tof';          % Options: nontof tof
rx.unlistType = 'gated';     % Options: static, dynamic, gated
rx.gatedBinMode = 'bypass';  % Options: percent, sppb, time, bypass
% Each start/end row vector specifies one gated frame:
% 3 frames, 5 sec intervals, with 10 sec gap between the 4 cycles
rx.startMsecVec = [ 0 25 50 75; ...
                    5 30 55 80; ...
                   10 35 60 85] * 1000;
rx.endMsecVec   = [ 5 30 55 80; ...
                   10 35 60 85; ...
                   15 40 65 90] * 1000;
data = UnlistMain(rx);


% Unlist in energy-mode (note: default LIST.BLF does NOT include energy info)
clear rx
rx.listFilePath = listFilePath;
rx.tofMode = 'tof';         % Options: nontof tof
rx.unlistType = 'static';   % Options: static, dynamic, gated
rx.startMsecVec = 0;        % beginning of exam
rx.endMsecVec   = 60 * 1000; % 1 minutes in [ms]
rx.lowEnergyLim  = 425;
rx.highEnergyLim = 650;
data = UnlistMain(rx);


% Unlist with max number of counts
clear rx
rx.listFilePath = listFilePath;
rx.tofMode = 'tof';          % Options: nontof tof
rx.unlistType = 'static';    % Options: static, dynamic, gated
rx.startMsecVec = 0;         % beginning of exam
rx.endMsecVec   = 60 * 1000; % 1 minutes in [ms]
rx.acqTotalCounts = 30e6;
data = UnlistMain(rx);



