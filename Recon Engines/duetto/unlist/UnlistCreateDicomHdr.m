% UnlistCreateDicomHdr(rx, filePathOut, acqDuration, imageNum, fileNum, frameNum, totalPrompts)
% 
% Create a DICOM header file for a sino file based on the DICOM header file associated with a list file.
%
% rx           - struct as setup in UnlistMain.m
% filePathOut  - DICOM header file associated with sino file
% acqDuration  - in seconds
% fileNum      - one relative file number (e.g. fileNum=3 for SINO0002)
% frameNum     - one relative frame number (usually the same as fileNum, but not always for gated)
% totalPrompts - 
% frameStartSec
%
% Copyright (c) 2020 General Electric Company. All rights reserved.
