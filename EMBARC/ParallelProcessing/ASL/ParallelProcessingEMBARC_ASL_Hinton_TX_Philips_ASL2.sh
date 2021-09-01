MatlabPath=/opt/amc/matlab/R2019b/bin/matlab;
DatasetRoot=/data/projects/EMBARC/EMBARC_ASL/TX_Philips;
# remove any locked folders
rm $DatasetRoot/derivatives/ExploreASL/lock/*/*/*/locked -d; # remove locked folders
xASLdir=/home/hjmutsaerts/scratch/ExploreASL;
screenName=EMBARC_ASL_TX_PhilipsFinalize;
cd $xASLdir;
screen -dmSL $screenName nice -n 10 $MatlabPath -nodesktop -nosplash -r "cd('$xASLdir');ExploreASL('$DatasetRoot', 0, [0 1 0], false, 1, 1);system('screen -SX $screenName kill');" &
# this will process any residual scans & create an overview report
