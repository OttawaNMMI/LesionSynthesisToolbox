% fix lesion data - prior to June 2020, neglected to account for background
% (patient) activity in adding lesion activity; thus lesion activity (and
% contrast with liver refrence) is higher than desired. This function batch
% fixes the recorded contrast levels in the lesionParams files.
%
% Ran Klein 2020-06-03

dir = 'E:\LSP Database\Synthetic lesion library\Mediastinal lymph node relative liver';
files = listfiles('*_LesionParams.mat',dir,'s');
nfiles = length(files);
for i = 1:nfiles
	lesionData = load([dir filesep files{i}]);
	lesions = lesionData.lesion;
	if ~isfield(lesions{1},'PTadditionMode') % need repair?
		disp(['Processing ' files{i}])
		[p, f, e] = fileparts(files{i});
		p1 = split(p,filesep);
		
		% Load the patient image file
		baselineImgFile = [dir filesep p1{1} filesep 'Baseline_PET' filesep strrep(f, '_LesionParams','_fIR3D') '.mat'];
		baselineImgData = load(baselineImgFile);
				
		% Sample the reference ROI PET activities from the baseline image
		refROI = lesionData.refROI;
		nRefROIs=length(refROI);
		refROInames = cell(nRefROIs,1);
		for ri=1:nRefROIs
			refROI{ri}.PTintensity = sampleROI(baselineImgData, refROI{ri});
			refROInames{ri} = refROI{ri}.name;
		end
		
		nLesions = length(lesions);
		for li=1:nLesions
			lesion = lesions{li};
			switch lesion.mode % TO DO - does background subtraction happen during simulation?
				case 'Lesion:Background'
					PTvalNew = lesion.PTval * + 1;
				case 'Bq/cc'
					PTvalNew = lesion.PTval + sampleROI(baselineImgData, lesion);
				otherwise
					indx = strfind(lesion.mode,':');
					if length(indx) == 1
						ROIname1 = lesion.mode(indx+1:end);
						ri = find(strcmpi(ROIname1,refROInames));
						if length(ri) == 1
							PTvalNew = (lesion.PTval*refROI{ri}.PTintensity + sampleROI(baselineImgData, lesion)) / refROI{ri}.PTintensity;
						else
							error(['Could not resolve a reference ROI named ' ROIname1])
						end
					else
						error(['Could not resolve lesion intensity mode' lesion.mode])
					end
			end
			
			if isnan(PTvalNew)
				disp([lesion.name '(' lesion.mode '): ' num2str(lesion.PTval) ' returned NaN!!! No fix made.'])
			else
				assert(PTvalNew > lesion.PTval)
				disp([lesion.name '(' lesion.mode '): ' num2str(lesion.PTval) ' --> ' num2str(PTvalNew)])
				lesion.PTval = PTvalNew;
			end
			
			lesion.PTadditionMode = 'Final (Maintain Texture)';
			lesions{li} = lesion;
		end			
		
		lesionData.lesion = lesions;
		if 1
			% keep a backup copy of the original lesionParams file
			movefile([dir filesep files{i}], [dir filesep p filesep f '-backup' e])
			% replace the original lesionParams file
			save([dir filesep files{i}],'-struct', 'lesionData');
		else
			% leave the original file and save in a new one
			save([dir filesep p filesep f '-fixed' e],'-struct', 'lesionData');
		end
	end
end




