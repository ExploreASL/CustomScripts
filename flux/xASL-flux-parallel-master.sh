#!/bin/bash
# Master script to create n instances of ExploreASL on the Flux server

# Set variables for Workerscript
let nWorkers=2;
MyScript=/scratch/mshammer/CustomScripts/flux/xASL-flux-parallel-worker.sh
xASLdir=/scratch/mshammer/ExploreASL;
DataFolder=/scratch/mshammer/OSIPI/Dataset6/; 

# Set to 1 if you want automatic lock-file removal
if 0; then
    rm $DataFolder/lock/*/*/*/locked -d; # remove locked folders
fi

# Set to 1 if you want an interactive slurm shell to test if the environmental variables are passed on correctly. 
if 0; then
    srun --export=ALL,WORKER=1,NWORKERS=$nWorkers,XASLDIR=$xASLdir,DATAFOLDER=$DataFolder --job-name 'interactive-shell' --cpus-per-task 1 --mem-per-cpu 4 --time 0:00:30 --pty bash
fi

# Make $nWorkers sBatch instances of $MyScript named  eg. xASL.1.3 (worker 1 of 3) use squeue to check status of running jobs.
for (( i=1; i<=$nWorkers; i++ ));
do
    sbatch --export=ALL,WORKER=$i,NWORKERS=$nWorkers,XASLDIR=$xASLdir,DATAFOLDER=$DataFolder --job-name 'xASL'.${i}.${nWorkers}.run $MyScript
done

exit 0
