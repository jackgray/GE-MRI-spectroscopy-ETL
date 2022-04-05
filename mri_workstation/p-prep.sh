#!/bin/bash

datapath=/home/sdc/data
rawpath=${datapath}/rawdata
logpath=${rawpath}/pprep.log

echo Running p-prep on $rawpath
echo

# Only run if .7 files are detected
if compgen -G "${rawpath}/*.7" > /dev/null; then

	echo Writing log file to $logpath
	exec > >(tee -i ${logpath})
	exec 2>&1 

	echo -e "\n\nBacking up rawdata to /home/sdc/rawdatabackup with rsync"
	rsync -aruvhzPrti --itemize-changes --stats --size-only --inplace --perms --owner --group --super /home/sdc/data/rawdata/*.7 /home/sdc/data/rawdatabackup

	echo -e "\n"$(date +"%c")"" 
	echo -e "\nRunning extract_nyspi_headers.py\n\n\n"
	# Collect header info and create map file for shell mv command 
	python3 /home/sdc/pipelines/p-pull/extract_nyspi_headers.py 2>&1>> /home/sdc/pipelines/p-pull/ppull.log

	# Read queue file and move files, then remove
	queue=/home/sdc/data/rawdata/move_queue.txt
	cat $queue | while read src dst; do mkdir -p $(dirname $dst) && mv $src $dst; done
	rm $queue
fi
