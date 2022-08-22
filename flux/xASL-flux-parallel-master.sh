#!/bin/bash
# Master script to create n instances of ExploreASL on the Flux server
# Author Maarten Hammer

let nWorkers=2;
MyScript=/scratch/mshammer/CustomScripts/flux/xASL-flux-parallel-worker.sh

for (( i=1; i<=$nWorkers; i++ ));
do
sbatch --export=ALL,WORKER=$i,NWORKERS=$nWorkers --job-name 'xASL'.${i}.${nWorkers}.run $MyScript
done