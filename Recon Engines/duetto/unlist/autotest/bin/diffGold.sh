#!/bin/bash

# diff all files in the gold-results/ directory with corresponding files in the given result-YYYY-MM-DD_hhmmss/ directory.
# a sed filter (i.e. 'filter.sed') is applied to both files before the diff command is run.

# Copyright (c) 2015 General Electric Company. All rights reserved.
# This code is only made available outside the General Electric Company
# pursuant to a signed agreement between the Company and the institution to
# which the code is made available.  This code and all derivative works
# thereof are subject to the non-disclosure terms of that agreement.
#
# History:
#    07-Oct-2015 initial version - Brian Flanagan

scriptDir="$(/usr/bin/dirname $(/bin/readlink -f $0))"
autotestEnvFile=${scriptDir}/autotestEnv.sh
if [ ! -f $autotestEnvFile ]; then
    echo "File not found: $autotestEnvFile"
    echo "You must run the matlab autoUnlistAll() script prior to running this bash script."
    exit 1
fi

source ${autotestEnvFile}

basenameCmd="/bin/basename"
lsCmd="/bin/ls"
diffCmd="/usr/bin/diff"
sedCmd="/bin/sed"
rmCmd="/bin/rm"
mktempCmd="/bin/mktemp"

scriptName=$($basenameCmd $0)
ExitUsage()
{
    cat << EOF

Usage: $scriptName <result directory path>
   
EOF
    exit $1
}

if [ -z $1 ] ; then
    ExitUsage 1
fi

resultDirPath=$1

if [ ! -d $resultDirPath ]; then
    echo "not a directory: $resultDirPath"
    ExitUsage 2
fi

tempDirPath=$($mktempCmd -dt "${scriptName}.XXXXXXXXXX")
# echo "tempDirPath: $tempDirPath"

# for each gold file, diff with file with same name in $resultDirPath

allPass=true
for goldFilePath in $($lsCmd -1 ${goldDirPath}/auto*.txt) ; do
    fileName=$($basenameCmd $goldFilePath)
    resultFilePath="${resultDirPath}/${fileName}"
    diffFilePath="${resultDirPath}/${fileName}.diff"
    echo -n "*** diff: $resultFilePath "
    if [ ! -f $resultFilePath ]; then
        echo "*** missing: $resultFilePath ***" > $diffFilePath
        echo "fail ***"
        echo
        allPass=false
        continue
    fi
    resultFilePathTmp="${tempDirPath}/${fileName}.result"
    goldFilePathTmp="${tempDirPath}/${fileName}.gold"
    $sedCmd -f $sedFilterPath $resultFilePath > $resultFilePathTmp
    $sedCmd -f $sedFilterPath $goldFilePath > $goldFilePathTmp
    if $diffCmd -w -B -c $goldFilePathTmp $resultFilePathTmp &> $diffFilePath
    then
        echo "pass ***"
    else
        echo "fail ***"
        allPass=false
    fi
    echo
done

$rmCmd -rf $tempDirPath

if [ "$allPass" = true ]; then
echo "All test cases passed."
else
echo "One or more test cases failed, please review \"${resultDirPath}/*.diff\" files."
fi
    
