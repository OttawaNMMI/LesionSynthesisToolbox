% Input:
%     Dicom filename OR Dicom header structure
%     If Dicom header structure, must be opened with pet-dicom-dict.txt.
%
% Output:
%     Net activity at scan start:
%
% Important Dicom fields:
%    (0009,1038) : tracer_activity   - Pre injection measurement
%    (0009,103c) : post_inj_activity - Post injection measurement
%    (0009,1039) : meas_datetime     - Pre injection time / date
%    (0009,103d) : post_inj_datetime - Post injection time / date
%    (0009,103f) : half_life         - Half life
%    (0009,100d) : scan_datetime     - Scan Date/Time, decay corrected to here
%    (0010,1030) : PatientsWeight    - Patient Weight in kg
