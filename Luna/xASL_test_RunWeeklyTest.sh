#!/bin/bash
# Script to run all weekly tests.
# Turn on/off the booleans to activate certain tests.

# set command to current matlab
Matlab=matlab-R2019b 

# Get info from config Json
settingsArray=(XASLDIR FlavorTestConfig FlavorDir TestDataSetSourceDir UnitTestingDir ResultMasterDir EmailAdress bPull bSPMTest bUnitTest bFlavorTest bTestDataSet bCompile bSummary bEmail iNiceness)
for Element in ${settingsArray[@]}; do
	export "${Element}=`jq .${Element} xASL_test_ConfigWeeklyTest.json -r`"
done

# Temporary Folders, ALL CONTENT WILL BE REMOVED FROM THIS FOLDER.
ReferenceTSV=${XASLDIR}/Testing/Reference/ReferenceValues.tsv
TestDataSetWorkspaceDir=${TMP}/TestDataSetWorkspace

# Make the results directory timed conform ISO 8601
today=$(date +"%FT%H:%M%:z") 
ResultDirToday=${ResultMasterDir}/${today}
mkdir ${ResultDirToday}
VersionFile=${ResultDirToday}/VersionsTested.txt
LogFile=${ResultDirToday}/LogFile.txt
touch ${VersionFile}

# Initialize some variables
cd ${XASLDIR}

# Get current Commit hash
RepositoryVersion=`git rev-parse --short HEAD` 
echo "We're testing version on ExploreASL version ${RepositoryVersion}." >>  ${VersionFile}

# Print settings
for Element in ${settingsArray[@]}; do
	printf "%-20s %s\n" ${Element} "was set to ${!Element}" >> ${VersionFile}
done


# Run SPM test (no output?, fix that)
if ${bSPMTest}; then
	# Run Explore ASL on the TestDataSet Directory
	# Copy to a reference location and go there

	# Go to directory and fetch latest version.
	cd ${TestDataSetSourceDir}
	if ${bPull}; then
		git pull
	fi

	rm -rf ${TestDataSetWorkspaceDir}
	cp -R ${TestDataSetSourceDir} ${TestDataSetWorkspaceDir} 
	echo "SPMTest was conducted in ExploreASL version ${RepositoryVersion}." >>  ${VersionFile}

	cd ${XASLDIR}
    nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('${XASLDIR}');ExploreASL();xASL_test_SPM('${TestDataSetWorkspaceDir}', false);exit;"

	# Clean up temporary files
	rm -rf ${TestDataSetWorkspaceDir}
fi

# Run UnitTest
if ${bUnitTest}; then

	# Go to directory and fetch latest version.
	cd ${UnitTestingDir}
	if ${bPull}; then
		git pull
	fi

	UnitVersion=`git rev-parse --short HEAD` 
	cd ${XASLDIR}
	echo "Unit test directory was tested on version ${UnitVersion}." >>  ${VersionFile}

    nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('${XASLDIR}');ExploreASL();xASL_test_UnitTesting(false);exit;"
	mv ${UnitTestingDir}/*results.mat ${ResultDirToday}
	mv ${UnitTestingDir}/*comparison.tsv ${ResultDirToday}
fi

# Run Flavor Test Parallelize?
if ${bFlavorTest}; then
	# Go to directory and fetch latest version.
	cd ${FlavorDir}
	if ${bPull}; then
		git pull
	fi

	FlavorVersion=`git rev-parse --short HEAD` 
	cd ${XASLDIR}
	echo "Flavor database test directory was tested  on version ${FlavorVersion}." >>  ${VersionFile}

    nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('${XASLDIR}');ExploreASL();xASL_test_Flavors();exit;"
	mv ${XASLDIR}/Testing/*results.mat ${ResultDirToday}
	mv ${XASLDIR}/Testing/*comparison.tsv ${ResultDirToday}
	mv ${XASLDIR}/Testing/*flavor_loggingtable.tsv ${ResultDirToday}
fi

if ${bTestDataSet}; then
	# Run Explore ASL on the TestDataSet Directory
	# Copy to a reference location and go there
	cd ${TestDataSetSourceDir}
	if ${bPull}; then
		git pull
	fi

	TestDataSet=`git rev-parse --short HEAD` 
	echo "TestDataSet directory was tested on version ${TestDataSet}." >> ${VersionFile}

	cd ${XASLDIR}
	rm -rf ${TestDataSetWorkspaceDir}
	cp -R ${TestDataSetSourceDir} ${TestDataSetWorkspaceDir} 
	cd ${TestDataSetWorkspaceDir}

	# create an array of all folders in the reference directory
	FolderArray=(*/)
	lengthDir="${#FolderArray[@]}"
	cd ${XASLDIR}

	# Run all test
	for (( i=0; i<${lengthDir}; i++ ));
	do
		nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('$XASLDIR');ExploreASL();ExploreASL('${TestDataSetWorkspaceDir}/${FolderArray[i]}', 0, 1, false);exit;"
	done

	# Compare results to Reference Values
	nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('${XASLDIR}');ExploreASL();xASL_test_CompareReference('${ReferenceTSV}','${TestDataSetWorkspaceDir}');exit;"
	mv ${TestDataSetWorkspaceDir}/*.tsv ${ResultDirToday}
	mv ${TestDataSetWorkspaceDir}/*ResultsTable.mat ${ResultDirToday}

	# Clean up temporary files
	rm -rf ${TestDataSetWorkspaceDir}
fi

if ${bCompile}; then
	mkdir ${ResultDirToday}/compilation
	nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('${XASLDIR}');ExploreASL();xASL_dev_MakeStandalone('${ResultDirToday}/compilation','${TestDataSetWorkspaceDir}');exit;"
fi

if ${bSummary}; then
	nice -n ${iNiceness} ${Matlab} -nodesktop -nosplash -r "cd('${XASLDIR}');ExploreASL();xASL_test_Summarize('${ResultDirToday}');exit;"
fi

if ${bEmail}; then
	echo "bEmail was ${bEmail}" >> ${VersionFile}
	cd ${ResultDirToday}

	# Email when outputfile exists and is not empty, delete empty output if exists
	if [ -s ${RepositoryVersion}_Results.txt ]; then
		echo "Sending email to ${EmailAdress}" >> ${VersionFile}
		mail -s 'xASL git commit detected' -a ${RepositoryVersion}_Results.txt m.hammer@amsterdamumc.nl <<< 'Git commit ${RepositoryVersion} resulted in changes in the test results.\n Changes are attached in the text file.' 
		exit 0
	else 
		echo "No Changes detected, no email has been sent." >>  ${VersionFile}
		rm ${RepositoryVersion}_Results.txt 
		exit 0
	fi 
fi
