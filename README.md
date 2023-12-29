# LesionSynthesisToolbox
A toolbox for synthesizing artificial lesions into PET and CT data.

The Lesion Synthesis Tooldbox (LST) is an open source Matlab webapp that can be run in Matlab, deployed as a standalone executable, or hosted as a web application. 

LST is designed to enable researchers to insert well characterized lesions into PET and CT data:
- In PET, the lesions are forward projected into the raw data and are then reconstructed. In our work we used the DUETTO toolbox from GE Healthcare, which requires a SDK (Software Development Kit) license. Reach out to Elizabeth Philps (Elizabeth.Philps@med.ge.com) to obtain access. We are happy to support other vendors. Please reach out to collaborate.
- In CT, the lesion values are written directly into the CT image.

## Development status
This tool is developed by graduate student at The Ottawa Hospital, Division of Nuclear Medicine and Molecular Imaging. To date, it has only been used internally for specific research projects and as such has undergone limited testing, and not of all functionalities. Consequently, it is likely that bugs exist. Please feel free to contribute and provide critical review.

All parts of this package are shared collaboratively, as is, with no garaunties or warranties. The developers do not assume any responsibility or liability for mistakes or damage that may ensue from using these tools. This is not a regulator approved product. 

## Getting started
To run the LesionSynthesisToolbox.mlapp which launches the main user interface.
User manual is included: https://github.com/OttawaNMMI/LesionSynthesisToolbox/blob/master/Lesion%20Synthesis%20Toolbox%20User%20Manual.pdf
