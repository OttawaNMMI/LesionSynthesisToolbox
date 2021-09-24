function SaveMAT2TIFF(img,filename) 

img = uint16(img); 

t = Tiff([filename],'w');

tagstruct.ImageLength     = size(img,1);
tagstruct.ImageWidth      = size(img,2);
tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample   = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip    = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software        = 'GABRANI_SINOGRAM_GENERATION';
t.setTag(tagstruct)

t.write(img);
t.close();
end 