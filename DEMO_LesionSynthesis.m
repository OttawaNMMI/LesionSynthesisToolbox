% Demonstration of lesion synthesis using example data.
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2019
% Last update: 2019-05-14

function DEMO_LesionSynthesis
path = fileparts(mfilename('fullpath'));
targetrDir = [path filesep 'Test Lesion Synthesis' filesep]; % target directory 
patientDataDir = [path filesep 'Test Lesion Synthesis' filesep '41038126']; % patient data directory
MakeLesionInsertionStudy(patientDataDir, targetrDir)
runLesionInsertionPlusRecon(patientDataDir, targetrDir)
end 