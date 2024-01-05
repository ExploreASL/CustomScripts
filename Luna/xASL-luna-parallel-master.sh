#!/bin/bash
# Master script to create n instances of ExploreASL on the Flux server

# Set variables for Workerscript
let nWorkers=2;
MyScript=/home/radv/mshammer/my-scratch/WeeklyTest/CustomScripts/Luna/xASL-luna-parallel-worker.sh
xASLdir=/home/radv/mshammer/my-scratch/ExploreASL;
DataFolder=/scratch/radv/mshammer/WeeklyTest/TestDataSets/Philips_3DGRASE_MultiSessions_T1wAlreadyDone_LoQ; 
niceness=1;

# Set to 1 if you want automatic lock-file removal
if true; then
    rm $DataFolder/derivatives/ExploreASL/lock/*/*/*/locked -d; # remove locked folders
fi

# Set to 1 if you want an interactive slurm shell to test if the environmental variables are passed on correctly. 
if false; then
    srun --export=ALL,WORKER=1,NWORKERS=$nWorkers,XASLDIR=$xASLdir,DATAFOLDER=$DataFolder --job-name 'interactive-shell' --cpus-per-task 1 --mem-per-cpu 4 --time 00:30:00 --pty bash
fi

# Make $nWorkers sBatch instances of $MyScript named  eg. xASL.1.3 (worker 1 of 3) use squeue to check status of running jobs.
if true; then
    for (( i=1; i<=$nWorkers; i++ )); do
        sbatch --export=ALL,WORKER=$i,NWORKERS=$nWorkers,XASLDIR=$xASLdir,DATAFOLDER=$DataFolder,NICENESS=$niceness --job-name 'xASL'.${i}.${nWorkers}.run $MyScript
    done
fi

exit 0