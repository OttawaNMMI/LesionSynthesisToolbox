rootDir = 'M:\Synthetic lesion library\AI - Copy'
%rootDir = 'C:\temp\Data to fix'
%rootDir = 'C:\Users\rklein\The Ottawa Hospital\Lesion Synthesis and Perception - Documents\Lesion Library\'

mode = 'fix'
% mode = 'show'

subdirs = listfiles('CTAC_DICOM.',rootDir,'sd');

disp(['Found ' num2str(length(subdirs)) ' directories to process:'])
for i=1:length(subdirs)
	dir = [rootDir filesep subdirs{i}];
	disp(['Processing ' dir])
	files = listfiles('*.*',dir);
	nfiles = length(files);

	% look at the first file
	filename = [dir filesep files{1}];
	info1 = dicominfo(filename);
	img = dicomread(info1);

	if min(img(:))<-2000 % alternatively ~=info1.SmallestImagePixelValue %need to fix
		if strcmpi(mode,'fix')
			img = repmat(img,1,1,nfiles); %initialize image
			info = cell(nfiles,1);
			filenamesOut = cell(nfiles,1);

			disp(['   Reading ' num2str(nfiles) ' files.'])
			for j=1:nfiles
				filename = [dir filesep files{j}];
				[~,~,index] = fileparts(filename);
				index = str2double(index(2:end));
				info{index} = dicominfo(filename);
				img(:,:,index) = dicomread(info{index});
				filenamesOut{index} = filename;
			end

% 			img = flip(img,3); % flip the slice order
			img = img - info1.RescaleIntercept; % account for rescale intercept and pixel value number format

			% save all the files

			disp(['   Saving ' num2str(nfiles) ' files.'])
			parfor j=1:nfiles
				dicomwrite(img(:,:,j), filenamesOut{j}, info{j}, 'CreateMode', 'copy');
			end
			disp(['   Fixed ' num2str(nfiles) ' files.'])
		else
			disp(['   Indentified ' num2str(nfiles) ' files to fix, but made no changes.'])
		end
	else
		disp('    No need to fix')
	end
end

