#!/bin/bash 

# optionally, remove unlist and result directories

# Copyright (c) 2015 General Electric Company. All rights reserved.
# This code is only made available outside the General Electric Company
# pursuant to a signed agreement between the Company and the institution to
# which the code is made available.  This code and all derivative works
# thereof are subject to the non-disclosure terms of that agreement.
#

scriptDir="$(/usr/bin/dirname $(/bin/readlink -f $0))"
autotestEnvFile=${scriptDir}/autotestEnv.sh
if [ ! -f $autotestEnvFile ]; then
    echo "File not found: $autotestEnvFile"
    echo "You must run the matlab autoUnlistAll() script prior to running this bash script."
    exit 1
fi

source ${autotestEnvFile}

rmCmd="/bin/rm"

echo "Top-level unlist autotest directory: $autotestDirPath"
echo "Remove unlist-<YYYY-MM-DD_hhmmss> directories? "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) $rmCmd -rf ${autotestDirPath}/exam*/list/unlist-20*; break;;
        No  ) break;;
    esac
done


echo "Remove result-<YYYY-MM-DD_hhmmss> directories? "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) $rmCmd -rf ${autotestDirPath}/result-20*; break;;
        No  ) break;;
    esac
done
