%  Radionuclide Total Dose (0018,1074) 3 DS 1 
%  Value depends on:
% tracer activity, 
% post injection activity, 
% half life, 
% measure date time, 
% admin date time, 
% post injection date time

%% 1) RadionuclideTotalDose

infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = info.HalfLife
L = log(2)/info.HalfLife;

infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = ...
	(tracerActivity * exp(-L*(datenum(measureDateTime,'yyyymmddHHMMSS')-datenum(AdminDateTime,'yyyymmddHHMMSS')) *24*60*60) ...
- PostInjectionActivity * exp(-L*(datenum(postInjectionDateTime,'yyyymmddHHMMSS')-datenum(AdminDateTime,'yyyymmddHHMMSS')) *24*60*60 ); % Bq

%% 2)

injectedActivity = infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose/1e6 *...
	exp(-log(2)/infodcm.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife * ... lambdah - time units = seconds
	(datenum(date) - datenum(injectedDateTime,'yyyymmddHHMMSS'))*24*60*60);

%% 3) hdrinitdcm 

%% 4) applyUptakeUnits 

