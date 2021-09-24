%  scatter=tofScatUpsample(dsScatter,nZ,nPhi,sV)
%
%  Performs scatter upsampling in u and v-theta
%  for scatter estimate at a particular value of
%  (already upsampled) phi.
%
%  Inputs: dsScatter         nZ*nU*nZ downsampled scatter array.
%          radialLocations   Target U positions in upsampled array.
%          nZ                Upsampled axial slice count.
%          sV                Plane spacing upsampled planes.
%          nPhiDS            Total number of phi (upsampled).
%          ringDiameter      Detector ring diameter.
%
%  Output      scatter    nVth*nU upsampled scatter array
