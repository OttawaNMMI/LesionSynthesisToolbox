% applyUptake Units - changes the units from activity concentration to 
% the desired uptake units.
% [myo_avg uptakeUnits metric status] = applyUptakeUnits(myo_avg, hdr,
% uptakeUnits)
% Input Parameters:
% myo_avg - activity concentration [Bq/cc]
% hdr - the image file header
% uptakeUnits - the desrired uptake units:
%               Activity [Bq/cc]
%               SUV-bw [g/mL]
%               SUV-lbm [g/mL]
%               SUV-bmi [g/mL m2]
%
% Output Parameters:
% myo_avg - converted units
% uptakeUnits - the output units {Bq/cc, mL/g, or mL/g m2}
% metric - the name of the metric {Activity or SUV}
% status - 1 units converted / 0 units not converted due to mising
% information in header.
%
% Note 1:
% To perform the conversion from activity to SUV the following parameters
% may be required from hdr: injectedActivity, patientWeight, patientHeight.
% If the required parameters are missing, the conversion will not be
% performed and Actvity [Bq/cc] units will be preserved for display.
%
% Note 2:
% It is assumed that injectedActivity has been decay corrected to scan 
% start time.

% by Ran Klein 2010-07-02
% 2011-01-28 RK Note 2 added.


% *******************************************************************************************************************
% *                                                                                                                 *
% * Copyright [2014] Ottawa Heart Institute Research Corporation.                                                   *
% * This software is confidential and may not be copied or distributed without the express written consent of the   *
% * Ottawa Heart Institute Research Corporation.                                                                    *
% *                                                                                                                 *
% *******************************************************************************************************************


function [myo_avg, uptakeUnits, metric, status] = applyUptakeUnits(myo_avg, hdr, uptakeUnits)

status = false;
switch uptakeUnits
	case ''
		status = false;
	case {'Activity [Bq/cc]','Bq/cc'}
		if ~iscell(myo_avg)
			maxactivity = max(myo_avg(:));
		else
			maxactivity = max(myo_avg{1}(:)); % normalize to maximum of LV PM
		end
        if maxactivity<2e-3
            uptakeUnits = 'uBq/cc';
            factor = 1e6;
        elseif maxactivity<2
            uptakeUnits = 'mBq/cc';
            factor = 1e3;
        elseif maxactivity>2e6
            uptakeUnits = 'MBq/cc';
            factor = 1e-6;
        elseif maxactivity>2000
            uptakeUnits = 'kBq/cc';
            factor = 1e-3;
        else
            uptakeUnits = 'Bq/cc';
			factor = 1;
        end
        metric = 'Activity';
        status = true;
	case {'SUV-bw [g/mL]','SUV'}
		if isfield(hdr,'patientWeight') && isfield(hdr,'injectedActivity') &&...
			~isempty(hdr.patientWeight) && ~isempty(hdr.injectedActivity) &&...
			 isscalar(hdr.patientWeight) && isscalar(hdr.injectedActivity) &&...
			 hdr.patientWeight>0 && hdr.injectedActivity>0
			factor = 1/(hdr.injectedActivity*1e6/(hdr.patientWeight*1000));
			uptakeUnits = 'g/mL';
			metric = 'SUV_{bw}';
			status = true;
		end
	case 'SUV-lbm [g/mL]'
		if isfield(hdr,'patientWeight') && isfield(hdr,'patientHeight') && isfield(hdr,'injectedActivity') && isfield(hdr,'patientSex') &&...
				~isempty(hdr.patientWeight) && ~isempty(hdr.patientHeight) && ~isempty(hdr.injectedActivity) && ~isempty(hdr.patientSex) &&...
				isscalar(hdr.patientWeight) && isscalar(hdr.patientHeight) && isscalar(hdr.injectedActivity) &&...
				hdr.patientWeight>0 && hdr.patientHeight>0 && hdr.injectedActivity>0
			% Lean body mass 
			if strcmpi(hdr.patientSex,'male')
				factor = 1/(hdr.injectedActivity*1e6)*...
					(1.10*hdr.patientWeight - 128*(hdr.patientWeight/(100*hdr.patientHeight))^2) * 1000;
			else
				factor = 1/(hdr.injectedActivity*1e6)*...
					(1.07*hdr.patientWeight - 148*(hdr.patientWeight/(100*hdr.patientHeight))^2) * 1000;
			end
			uptakeUnits = 'g/mL';
			metric = 'SUV_{lbm}';
			status = true;
		end
	case {'SUV-bmi [g/mL m2]', 'SUV-bmi [g/mL m�]', 'SUV-bmi [g m�/mL]'}
		if isfield(hdr,'patientWeight') && isfield(hdr,'patientHeight') && isfield(hdr,'injectedActivity') &&...
			~isempty(hdr.patientWeight) && ~isempty(hdr.patientHeight) && ~isempty(hdr.injectedActivity) &&...
			 isscalar(hdr.patientWeight) && isscalar(hdr.patientHeight) && isscalar(hdr.injectedActivity) &&...
			 hdr.patientWeight>0 && hdr.patientHeight>0 && hdr.injectedActivity>0
			factor = 1/(hdr.injectedActivity*1e6/(hdr.patientWeight*1000))*(hdr.patientHeight)^2;
			uptakeUnits = 'g/mL m^2';
			metric = 'SUV_{bmi}';
			status = true;
		end
	case 'Tracer Concentration [nmol/cc]'
		if isfield(hdr,'SpecificActivity') && ~isempty(hdr.SpecificActivity)
			if ischar(hdr.SpecificActivity)
				hdr.SpecificActivity = str2double(hdr.SpecificActivity);
			end
			if isscalar(hdr.SpecificActivity) && ...
					hdr.SpecificActivity>0
				factor = 1/hdr.SpecificActivity*1e-6; % [Bq/cc]/[GBq/umol] = nmol/cc*1e-6
				uptakeUnits = 'nmol/cc';
				metric = 'Tracer Conc.';
				status = true;
			end
		end
	otherwise
		error(['Unknown uptake units (' uptakeUnits ') specified.']);
end

if ~status
	uptakeUnits = 'Bq/cc';
    factor = 1;
	metric = 'Activity';
end

if iscell(myo_avg)
	for i=1:length(myo_avg)
		myo_avg{i} = myo_avg{i}*factor;
	end
else
	myo_avg = myo_avg*factor;
end