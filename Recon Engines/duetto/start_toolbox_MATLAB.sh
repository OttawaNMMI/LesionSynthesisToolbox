#!/bin/sh
# FILENAME: start_toolbox_MATLAB.sh
#
# PURPOSE:  Set up decompression filters (for RDFv10 processing) and start MATALB
#                   This function sets two environment variables and
#                   create a symbolic link
#
#
#  [NOTE]
#       *This script expects to be executed from the root Duetto directory.
#
#       *Please put the MATLAB installation location at line 17 
#         or the latest version in the default location (/usr/local/MATLAB) would be used.
#
#
# Copyright 2019 General Electric Company. All rights reserved.

# Please put location where the preferred MATLAB version is installed
# or the latest MATALB version installed in /usr/local/MATLAB would be used
MATLABROOT=$(ls -d /usr/local/MATLAB/* | tail -1);    

exe_txt=${MATLABROOT}/bin/matlab;

DUETTOROOT=${PWD};
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${DUETTOROOT}/io/rdf/hdf5_plugin_library/;
HDF5_PLUGIN_PATH=${DUETTOROOT}/io/rdf/hdf5_plugin_library/;
export LD_LIBRARY_PATH;
export HDF5_PLUGIN_PATH;

# Create a HDF5 symbolic link if not exists
FILE=${DUETTOROOT}/io/rdf/hdf5_plugin_library/libhdf5.so.10;
if test ! -f "$FILE"; then
    echo "libhdf5.so.10 does not exist. Create a symbolic link to the MATLAB HDF5 library";
    
    LIBFILE=$(ls ${MATLABROOT}/bin/glnxa64/libhdf5.so.*1 | tail -1);    
    ln -sf ${LIBFILE} ${FILE};    
fi

# start MATLAB  
${exe_txt} $*

exit

