Automates the process of getting MRS P-files from GE scanner to data analysis computing cluster.

1) (at MRI Console): Extract header information from P-files, name, and organize files according to bids standard
$ ./p-prep.sh

!! Requires GE Matlab header tools "get_MR_headers.m" in the same folder

2) (on cluster server): pull data off lab machine and organize into project folders (.../<project_id>/derivatives/MRS) with appropriate permissions
$ ./helpers/run.sh

The image for organizing the files requires bind-mounting /etc/group to /etc/group in the docker run configuration in order to retreive user/group info to apply permissions.
