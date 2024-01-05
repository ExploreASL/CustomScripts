#!/bin/bash
#SBATCH --mem=4G               # max memory per node
#SBATCH --cpus-per-task=1      # max CPU cores per MPI process
#SBATCH --time=0-04:00         # time limit (DD-HH:MM)
#SBATCH --partition=luna-short # luna-short is default, but use luna-long if time exceeds 8h
#SBATCH --nice=2000            # allow other priority jobs to go first (note, this is different from the linux nice command below)

# Worker script that runs one instance of ExploreASL on a (remote) terminal

if false; then
    echo $NWORKERS
    echo $WORKER
    echo $XASLDIR
    echo $DATAFOLDER
    echo $NICENESS
fi 


# run Script
nice -n $NICENESS `matlab-R2022b -nodesktop -nosplash -r "cd('$XASLDIR');ExploreASL('$DATAFOLDER', 0, 1, $WORKER, $NWORKERS);exit;"`
echo "xASL has ran as worker $WORKER of $NWORKER" 

exit 0
