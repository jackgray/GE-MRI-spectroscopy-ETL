#!/bin/bash

# Backup before manipulating filenames
echo -e "\n\nBacking up rawdata to /home/sdc/rawdatabackup with rsync"
rsync -rv --size-only --update --inplace --perms --owner --group --super /home/sdc/data/rawdata/*.7 /home/sdc/data/rawdatabackup

echo -e "\nRunning extract_nyspi_headers.py\n\n"
# Collect header info and create map file for shell mv command 
python3 /home/sdc/pipelines/p-pull/extract_nyspi_headers.py

# Python can't move .7 files--(embedded null byte error)
# Read queue file and move files
queue=/home/sdc/data/rawdata/move_queue.txt
cat $queue | while read src dst; do mkdir -p $(dirname $dst) && mv $src $dst; done
rm $queue