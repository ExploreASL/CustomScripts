# note to first remove any existing locked folders
let nParallel=4;
MatlabPath=/opt/amc/matlab/R2019b/bin/matlab;
DatasetRoot=/data/projects/EMBARC/EMBARC_ASL/MG_Siemens;
# rm $DataFolder/lock/*/*/*/locked -d; # remove locked folders
# rf $DataFolder/lock/xASL_module_Population; # Population lock folder
xASLdir=/home/hjmutsaerts/scratch/ExploreASL;
screenName=EMBARC_ASL_MG_Siemens;
cd $xASLdir;
for (( i=1; i<=$nParallel; i++ ));
do screen -dmSL $screenName$i nice -n 10 $MatlabPath -nodesktop -nosplash -r "cd('$xASLdir');ExploreASL('$DatasetRoot', 0, [0 1 0], false, $i, $nParallel);system('screen -SX $screenName$i kill');" &
done


# note to remove locks
