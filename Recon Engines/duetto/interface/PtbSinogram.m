    % Class to store/descripte GE PET projection sinograms for both 2D and 3D
    %   nU, nV, nPhi, nT (data dimensions of full sinogram)
    %   sU, sV, dT       (pixel size, TOF sampling size)
    %   nZ, nTheta       (oblique slice information)
    %   phiAngles        (phi angle index for subset data)
    %   phiAngleOffset   (also called rotate)
    %   radialRepositionFlag
    %   nUrr             (number of radial repositoned bins) 
    % 
    % This class can be also used for subsets, the dimension of data in the 
    % subset is 
    %    nU, nV, numel(phiAngles), nT
    %   
