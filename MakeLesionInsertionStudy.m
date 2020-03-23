% MakeLesionInsertionStudy generates the necesssary files prior to lesion
% synthesis from an existing target patient directory. 
% 
% The function creates the lesion synthesis directory and prompts the user 
% to define the lesion(s) for simulation within the patient. This function 
% provides functionality to create multiple synthetic lesions in a single 
% patient with the added function to specify lesion-to-background contrast 
% factor.
%
% Lesion Synthesis at this time is only supported using the GE RECON 
% TOOLOX (VER: REGRECON5) for Time-of-flight reconstructions. For
% development/modifications/access to source code please contact 
% GE Healthcare PET image reconstrcution development team 
% (As of early 2019: Michael.Spohn@ge.com)
%
% This function uses tools from the GE RECON TOOLBOX (REGRECON5) and
% therefore needs REGRECON5 in the available directory
%
% Usage: 
% ======
% MakeLesionInsertionStudy(patdatadir, datastoredir) - Specify the directory where the
% target patient data is stored. 
%
% patdatadir - Typically this folder should have two
% stored directies within. The first is a CTAC folder with the slices of
% the patient CTAC image used to ATTEN CORR by the GE RECON TOOLBOX.
%
% datastoredir - directory where you want to store the data
%
% Next Step: runLesionInsertionPlusRecon(fname,patdatadir)
%
% Author: Hanif Gabrani-Juma, B.Eng, MASc (2019)
% Created: 2018
% Last Modified: April 30 2019


% FOR HANIF:
% - I added the new 4dViewer and fused display with CT
% - I had to permute the PET image for proper display, but hopefully will
% not cause errors - please test
% - Would be nice to display PET in SUV if possible
% - When I ran this I got many messages:
%     --------------------
%     Check Hanif Edit ^^^
%     --------------------
% - When I ran there are many messages regarding:
%    'cp' is not recognized as an internal or external command, 
%    operable program or batch file.
%  I think this is a Unix/Windows compatibility issue that we should be 
%  able to address using copyfile
% - Add logic to look for baseline reconstruction (with the correct
% parameters) and perform it if need be.

function MakeLesionInsertionStudy(patdatadir,datastoredir)

%patdatadir = '/media/hanif/HANIFHDD/Console Data/Local Patient DB/13187';
%datastoredir = 'C:\Users\hjuma\Documents\MATLAB\Lesion Synthesis DB';

[~, f, ~] = fileparts(patdatadir);

% Necessary that to follow this naming convention
reconName = ['Patient_' f];


imgGT = readSavefile([patdatadir filesep 'ir3d.sav']);
if exist([patdatadir filesep 'CTAC'],'dir')
	[CTvol, CThdr] = load_DICOMDirectory_scan([patdatadir filesep 'CTAC']);
	CTAC = twobyte2double(CTvol, CThdr.quant_dynamic);
	CTVolStruct = struct('vol',double(CTAC),...
	                 'pixelDimensions',[CThdr.pix_mm_xy, CThdr.pix_mm_xy, CThdr.pix_mm_z],...
					 'offset',[0 0 0],...
					 'colormap','bone',...
					 'clim',[0 300],...
					 'alpha',0.3);
else
	CTVolStruct = [];
end

% Create the HDR struct based on # of data elements
hdr.pix_mm_xy = 700/size(imgGT,1);
hdr.pix_mm_z = 3.27;
hdr.xdim = size(imgGT,1);
hdr.ydim = size(imgGT,2);
hdr.nplanes = size(imgGT,3);

% gen zero map for lesions
phantom = zeros(size(imgGT));

% Set flags
makeLesion = 1;
addLesion = 1;

% Necessary to tell lesion synthesis how many lesions in the dataset 
lesionCount = 1;

% Initialize Estimated Recon image with Lesions
ReconEstimate = imgGT;


% In View4D hit s to gen a lesion..< or > to change size..you will be
% promoted when you close View4D for lesion contrast factor and if you want
% to generate more lesionsS
if makeLesion
	
	while addLesion
						 
		[~, ROI] = View4D(permute(ReconEstimate,[2 1 3]),[],...
			  'PixelDimensions',[hdr.pix_mm_xy*[1 1] hdr.pix_mm_z],...
			  'AxisNames',{'Coronal','Sagittal','Transaxial'},... axis labels
			  'Units','Bq/cc',...% ideally would be SUV,... 
			  'ScaleLimitsMode',[0 10^4],... % ideally would be SUV
			  'Colormap','HotMetal',... The image colormap
			  'Secondvolume', CTVolStruct,...
			  'WaitForClose',true,...
			  'FigureName', 'Define lesion locations',...
			  'Position',[0 0.5 1 0.5],... 
			  'KeyPressFunc', @view4DROIKeyPressCallback); % Add a callback to draw ROIs.

		if 0
			[contrast, radius, CTintensity] = LesionPropertiesGUI;
		else
			contrast = inputdlg('Enter Lesion Contrast Factor','Lesion Generation Parameters',[1 35],{'1.5'});
			if isempty(contrast)
				return;
			else
				contrast = str2double(contrast);
			end
		end
		
		addLesion = questdlg('Would you like to add another lesion','Lesion Insertion Toolbox','Yes','No','No');
		switch addLesion
			case ''
				addLesion = 0;
			case 'Yes'
				addLesion = 1;
			case 'No'
				addLesion = 0;
		end
		
		switch lower(ROI.shape)
			case 'sphere'
				[phantom] = MakeSphere(phantom,hdr,....
					ROI.coord(2)/hdr.pix_mm_xy,...
					ROI.coord(1)/hdr.pix_mm_xy,...
					ROI.coord(3)/hdr.pix_mm_z,...
					ROI.radius, contrast);
			otherwise
				error(['Unknown ROI shape encountered: ' ROI.shape]);
		end
		
		if length(contrast) > 1
			ReconEstimate(phantom) = inf;
			disp('Lesion Intensity Dramatisized for Visualization')
		else
			ReconEstimate(:,:,:,1) = imgGT.*phantom.*contrast + ReconEstimate(:,:,:,1);
		end
		if ~isempty(CTVolStruct)
			% TO DO - not so simple - must account for different number of
			% voxels.
% 			CTVolStruct.vol(phantom) = CTintensity;
		end
		
% FOR HANIF - can the commented section below be deleted?
		%[phantom] = MakeAsymSphere(phantom,hdr,ceil(ROI_x/hdr.pix_mm_xy),...
		%ceil(ROI_y/hdr.pix_mm_xy),ceil(ROI_z/hdr.pix_mm_z),ROI_r,res);
		
		% Lesion Synthesis Necessary Parameters 
		lesion{lesionCount}.map = phantom;
		lesion{lesionCount}.uptake = contrast;
		lesionCount = lesionCount + 1;
		phantom = zeros(size(imgGT));
		
	end
	
	% Make the dir to save the lesion synthesis study files
	mkdir(datastoredir,reconName)
	
	% Save the lesion binary map and other necessary parameters
	save([datastoredir filesep reconName filesep 'LesionParams_' reconName '.mat'],'lesion','lesionCount')
	
end

end



function view4DROIKeyPressCallback(hObject, key, handles)
switch key
	case {'s','S'} % add a sphere
		% Make a 1 cm sphere ROI
		d = 10; %mm
		ROI_r = d/2; %mm 
		dim = getappdata(handles.View4DFigure,'PixelDimensions');
		[y0,x0,z0] = View4DCoord(hObject,'',handles); 
        %disp(['Rad = ' num2str(r)])
		disp(['Diameter = ' num2str(2*ROI_r)])
		[theta, phi] = meshgrid((0:5:360)/180*pi, (0:5:180)/180*pi);
		x = x0 + ROI_r*sin(phi).*cos(theta)/dim(1);
		y = y0 + ROI_r*sin(phi).*sin(theta)/dim(1);
		z = z0 + ROI_r*cos(phi)/dim(3);
		contour{1} = struct('X',x,...
			                'Y',y,...
							'Z',z,...
							'LineStyle','-w',...
							'Type','mesh');
		setappdata(handles.View4DFigure,'Contour',contour);
		updateView4DSlices(handles)

	case {'.',','} 
		if key=='.' % make ROI radius bigger
			factor = 1.1;
		else % make ROI radius smaller
			factor = 1/1.1;
		end
		contour = getappdata(handles.View4DFigure,'Contour');
		if ~isempty(contour)
			x0 = mean(contour{1}.X(:));
			y0 = mean(contour{1}.Y(:));
			z0 = mean(contour{1}.Z(:));
			contour{1}.X = (contour{1}.X - x0) * factor + x0;
			contour{1}.Y = (contour{1}.Y - y0) * factor + y0;
			contour{1}.Z = (contour{1}.Z - z0) * factor + z0;
			setappdata(handles.View4DFigure,'Contour',contour);
			updateView4DSlices(handles)
			
			dim = getappdata(handles.View4DFigure,'PixelDimensions');
% 			ROI_x = mean(contour{1}.X(:))*dim(1);
% 			ROI_y = mean(contour{1}.Y(:))*dim(2);
% 			ROI_z = mean(contour{1}.Z(:))*dim(3);
			ROI_r = (max(contour{1}.X(:)) - min(contour{1}.X(:)))*dim(1)/2;
			%disp(['Lesion location ' num2str(ROI_x) ', ' num2str(ROI_y) ', ' num2str(ROI_z) ' and size is ' num2str(ROI_r) ' mm'])
			disp(['Diameter = ' num2str(2*ROI_r)])
		end
end
handles.output = struct('shape','Sphere',...
                        'coord',[x0, y0, z0],...
						'radius',ROI_r);
					
guidata(handles.View4DFigure, handles);
end