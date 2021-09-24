i = 1;


reconDB = 'C:\temp\Discovery_DR\Clean Liver Recons';
load('C:\Users\hjuma\OneDrive - The Ottawa Hospital\Papers in Progress\MIPs Special Edition 2019\MIPs_LesionParams_fxyz.mat')


for i = 1:length(x)
    disp(['*************** ' num2str(i) '/' num2str(length(x)),...
        ' ***************'])
    
    load(f{i})
    
    disp(['FILE: ' f{i}])
    disp(['SCAN: ' info.reconName])
    
    if exist(info.patdatadir)
        reconDir = info.patdatadir;
        
    else % Does not exist
        [~, reconNum,] = fileparts(info.patdatadir);
        reconDir = [reconDB filesep reconNum];
        
        
    end
    
    %imgGT = readSavefile([reconDir filesep 'ir3d.sav']);
    load([reconDir filesep 'IR3D_SUV.mat'])
    imgGT = img;
    
    % Example Usage:
    hdr.pix_mm_xy = 700/size(imgGT,1);
    hdr.pix_mm_z = 3.27;
    hdr.xdim = size(imgGT,1);
    hdr.ydim = size(imgGT,2);
    hdr.nplanes = size(imgGT,3);
    
    ROI_x = x(i); % Units are in pixels
    ROI_y = y(i); % Units are in pixels
    ROI_z = z(i); % Units are in pixels
    ROI_r = hdr.pix_mm_xy*4; % Units are in mm
    
    [vol] = MakeSphere(imgGT,hdr,ROI_x,ROI_y,ROI_z,ROI_r,1);
    
    ROI3D = vol.*imgGT;
    
    ROI3D(ROI3D==0) = NaN;
    stdROI(i) = nanstd(ROI3D(:));
    meanROI(i) = nanmean(ROI3D(:)); 
    disp(['MEAN: ' num2str(meanROI(i))]) 
    disp(['STD:  ' num2str(stdROI(i))])
end

disp('COMPLETE')