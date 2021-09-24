function reconLocalDB 
datadir = 'C:\Users\hjuma\Documents\MATLAB\GE FTP\Local DB'; 
sMRN = xlsread([datadir filesep 'MRN2Search.xls']);
for i = 1:length(sMRN)    
    if exist([datadir filesep num2str(sMRN(i))])
        disp(sMRN(i))
        cd([datadir filesep num2str(sMRN(i))]) 
        GEPETreconparamsBaselineRecon 
        [reconImg] = GEPETrecon(reconParams); 
    end
end 
end 