%
% FILE NAME: UnlistWrapper.m
%
% This function is a wrapper for the unlister function. If
% successful, the unlister will create a folder in the current directory 
% that starts with the 'unlist' prefix and incorporates the date and time 
% into the folder name. A subfolder within the 'unlist' folder called 'raw'
% is also created.
% The output of the unlisting process consists of an RDF sinogram and a 
% DICOM header, which are saved in the 'raw' subfolder. 
%
% INPUTS:
%       input_List: filename of the LST file
%       StartVec: Start time vector in milliseconds relative to the start of the frame
%       EndVec: End time vector in milliseconds relative to the start of the frame
%       Mode: 'tof' or 'nontof'
%       unlist_Type: 'static', 'dynamic', or 'gated'
%
% OPTIONAL INPUTS: (use in pairs of the 'key' followed by the 'value'
%       TrigRejMin: in milliseconds, used to the define the minimum interval allowable
%               between triggers. Default Off
%       TrigRejMax: in milliseconds, used to the define the maximum interval allowable
%               between triggers. . Default Off
%       gatedWaitForFirstTrig: Optional, in gated mode, Options are 'respiratory' or 'cardiac'.
%                   respiratory: skip prompt events until first respiratory trigger is detected in LST file
%                   cardiac: skip prompt events until first cardiac trigger is detected in LST file
%       gatedBinMode: Required for gating mode only, options are 'time', 'percent', 'bypass'. Default is 'bypass'
%                    time: performs time binning for gated unlisting
%                    percent: performs percent binning for gated unlisting
%                    bypass: assumes StartVec and EndVec are 2-D matrices in which each row contains 
%                            the start and end times for a single gate 
%       gatedBinVec: Required for time or percent gating mode only, specifies the time in
%                millisecond or percentage duration that are assigned to each bin. 
%                time bin example: [1000 1500 1300 1000]
%                percent bin exmaple: [25 20 15 40]
%       
%
% OUTPUTS:
%       rx: structure that defines the parameters of the unlisting process 
%
% USAGE: 
% rx = UnlistWrapper('/home/myfolder/LIST0000.BLF', 0, 60000, 'tof', 'static')
% rx = UnlistWrapper('/home/myfolder/LIST0000.BLF', [0; 10000; 40000], [10000; 40000; 60000], 'nontof', 'dynamic')
% rx = UnlistWrapper('/home/myfolder/LIST0000.BLF', [0 10000 40000;5000 20000 50000], ...
%                     [5000 20000 50000; 10000, 40000, 60000], 'tof', 'gated')
% USAGE with optinal inputs:
% rx = UnlistWrapper('/home/myfolder/LIST0000.BLF', [0 10000 40000;5000 20000 50000], ...
%                      [5000 20000 50000; 10000, 40000, 60000], 'tof', 'gated', 'gatedBinMode', 'bypass')
% => creates 2 gated bins
%
% Notes:
% 1) Make sure that a LST file and its corresponding dicom header are located in the
%    folder path portion of input_List
% 2) For unlist_Type = 'static', StartVec and EndVec are 1x1 variables
% 3) For unlist_Type = 'dynamic', StartVec and EndVec are 1-D vectors
% 4) For unlist_Type = 'gated', and for gatedBinMode = 'time' or 'percent', 
%    the Unlister will assume that StartVec and EndVec are 1-D vectors indicating
%    the triggers. The code will divide each interval between triggers according to 
%    gatedBinVec and assign each portion to a seperate gate.
% 5) For unlist_Type = 'gated', and for gatedBinMode = 'bypass', the StartVec and EndVec
%    are 2-D matrices in which each row contains the individual start and end times for a single bin
% 6) When using custom triggers that are not located in LST file, do not sp
