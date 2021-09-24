% FILENAME: ptbSetDicomOrientationFieldsFromPatientPosition
%
% Find dicomHdr.ImageOrientationPatient, etc from PatientPosition
%
% INPUTS:
%	  dicomHdr: structure returned from dicominfo
%
% OUTPUTS:
%     dicomHdr: updated dicomHdr
%
% USAGE:
%     dicomHdr = setDicomOrientationFieldsFromPatientPosition(dicomHdr);
%         Sets ImageOrientationPatient, PatientOrientationCodeSequence,
%         PatientOrientationModifierCodeSequence, PatientGantryRelationshipCodeSequence
%
% Copyright 2018 General Electric Company.  All rights reserved.
