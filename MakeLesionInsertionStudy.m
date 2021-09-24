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
% MakeLesionInsertionStudy(patdatadir) - Specify the directory where the
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

function MakeLesionInsertionStudy(patdatadir,datastoredir,reconName)

%patdatadir = '/media/hanif/HANIFHDD/Console Data/Local Patient DB/13187';
%datastoredir = 'C:\Users\hjuma\Documents\MATLAB\Lesion Synthesis DB';

[p f e] = fileparts(patdatadir);

% Necessary that to follow this naming convention
if isempty(reconName)
	reconName = ['Patient_' f];
end

imgGT = readSavefile([patdatadir filesep 'ir3d.sav']);
if exist([patdatadir filesep 'CTAC.mat'])
	load([patdatadir filesep 'CTAC.mat']);
	CTAC = twobyte2double(vol,hdr.quant_dynamic);
end

% Create the HDR struct based on # of data elements
hdr.pix_mm_xy = 700/(2*size(imgGT,1));
hdr.pix_mm_z = 3.27;
hdr.xdim = 2*size(imgGT,1);
hdr.ydim = 2*size(imgGT,2);
hdr.nplanes = size(imgGT,3);

% gen zero map for lesions..twice the size of the target image (rescaled
% later)
phantom = zeros([2*size(imgGT,1),2*size(imgGT,2),size(imgGT,3)]);

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
		
		[frames,ROI_x,ROI_y,ROI_z,ROI_r] = View4D(ReconEstimate,[],'PixelDimensions',[2*hdr.pix_mm_xy*[1 1] hdr.pix_mm_z], 'WaitForClose',true, 'FigureName', '4dview');
		res = inputdlg('Enter Lesion Contrast Factor','Lesion Generation Parameters',[1 35],{'1.5'});
		if isempty(res)
			res = 1.5;
		else
			res = str2double(res);
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
		
		[phantom] = MakeSphere(phantom,hdr,ceil(ROI_x/hdr.pix_mm_xy),...
			ceil(ROI_y/hdr.pix_mm_xy),...
			ceil(ROI_z/hdr.pix_mm_z),ROI_r,res);
		
		phantom = imresize3(phantom,[size(imgGT,1),size(imgGT,2),size(imgGT,3)]); 
		
		if res < 3
			ReconEstimate(:,:,:,1) = imgGT.*res.*10.*phantom + ReconEstimate(:,:,:,1);
			disp('Lesion Intensity Dramatisized for Visualization')
		else
			
			ReconEstimate(:,:,:,1) = imgGT.*phantom.*res + ReconEstimate(:,:,:,1);
		end
		
		%[phantom] = MakeAsymSphere(phantom,hdr,ceil(ROI_x/hdr.pix_mm_xy),...
		%ceil(ROI_y/hdr.pix_mm_xy),ceil(ROI_z/hdr.pix_mm_z),ROI_r,res);
		
		% Lesion Synthesis Necessary Parameters 
		lesion{lesionCount}.map = phantom;
		lesion{lesionCount}.uptake = res;
		lesionCount = lesionCount + 1;
		
		phantom = zeros([2*size(imgGT,1),2*size(imgGT,2),size(imgGT,3)]);
		
		info.reconName = reconName; 
		info.patdatadir = patdatadir; 
		info.datastoredir = datastoredir; 
	end
	
	% Make the dir to save the lesion synthesis study files
	mkdir([datastoredir],reconName)
	
	% Save the lesion binary map and other necessary parameters
	save([datastoredir filesep reconName filesep 'LesionParams_' reconName '.mat'],'lesion','lesionCount','info')
	
end

end