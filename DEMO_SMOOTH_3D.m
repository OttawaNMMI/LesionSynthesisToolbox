function DEMO_SMOOTH_3D 

datadir = 'C:\Users\hjuma\Documents\MATLAB\Lesion Synthesis DB\Patient_41038126\CTreconWithLesion'; 

vol = readSavefile([datadir filesep 'ir3d.sav']); 

hdr = hdrinitdcm('C:\Users\hjuma\Documents\MATLAB\Lesion Synthesis DB\Patient_41038126\CTreconWithLesion\Synthetic_Lesion_Offline_3D\_bin1_sl296.sdcopen'); 

vol2 = smooth3d(vol, hdr, 6.4, 3.2);


end 