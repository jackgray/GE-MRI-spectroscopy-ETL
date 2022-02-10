#!/bin/env bash

# Run rsync locally to use local ssh config
ionice -c 3 rsync -havzpPrti --itemize-changes --stats --exclude-from=/MRI_DATA/nyspi/MRS_purgatory/.rsyncignore -e 'ssh -o StrictHostKeyChecking=no' sdc:/home/sdc/data/rawdata/converted/* /MRI_DATA/nyspi/MRS_purgatory

VERSION=$1

############################## CONTAINER SETUP #################################
image_name=jackgray/ppull:${VERSION}
#----------SERVICE NAME---------------
service_name=p_pull
#-------------------------------------

# Data Locations
allprojects_path_doctor=/MRI_DATA/nyspi
allprojects_path_container=${allprojects_path_doctor}   # make directory structure identical  
purgatory_path_doctor=${allprojects_path_doctor}/MRS_purgatory
purgatory_path_container=${purgatory_path_doctor}
groups_path_doctor=/etc/group
groups_path_container=/etc/group

# Organize files inside container for root access
docker_run(){
/usr/bin/docker run \
-it \
--rm \
--mount type=bind,source=${allprojects_path_doctor},destination=${allprojects_path_container} \
--mount type=bind,source=${purgatory_path_doctor},destination=${purgatory_path_container} \
--mount type=bind,source=${groups_path_doctor},destination=${groups_path_container} \
--name ${service_name} \
${image_name}
}

docker_run