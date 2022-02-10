#!/home/sdc/anaconda3/bin/python36

from subprocess import run
from zlib import compress
from datetime import date
from os import mkdir, path, makedirs, rename
from shutil import move
from glob import glob
import matlab.engine
import io
from copy import copy

eng = matlab.engine.start_matlab()
out = io.StringIO()
err = io.StringIO()

rawdata_path = '/home/sdc/data/rawdata'
pfiles = glob(rawdata_path + '/*.7')
compressed_pfiles = glob(rawdata_path + '/*.gz')
converted_path = "/home/sdc/data/rawdata/converted"
changemap_path = path.join(converted_path, "change_map.log")
move_queue_path = path.join(rawdata_path, "move_queue.txt")
print("\n\nScaning rawdata for new P-files to convert...")

if len(pfiles) > 0:
	print("Detected new files in rawdata to send to cluster. Creating a map file for renaming and transfer.")
	date = date.today().strftime("%b-%d-%Y")

	with open(changemap_path, 'a') as logfile:
		logfile.write("\n" + date + "\n")

	for pfile in pfiles:
		# Call MATLAB to extract P-file header info
		proj_id, subj_id, exam_no, scan_no, series_desc = eng.extract_nyspi_headers(pfile, nargout=5, stdout=out, stderr=err)
		# Format MATLAB returns
		proj_id = proj_id.replace(" ", "").replace("_", "").replace("-", "").lower()
		subj_id = subj_id.replace(" ", "").replace("_", "").replace("-","").lower()
		series_desc = series_desc.replace(" ", "-").replace("_", "-").lower()
		# Display results
		orig_filename = path.basename(pfile)
		print("\n\n\n*******************************************************************")
		print("Pulled the following header info from ", orig_filename)
		print("Project ID: ", proj_id)
		print("Subj ID: ", subj_id)
		print("Exam #: ", exam_no)
		print("Scan #: ", scan_no)
		print("Series ID: ", series_desc)

		# Case for blank proj_id: default to 'test' project 
		if len(proj_id) > 0:
			proj_path = path.join(converted_path, proj_id)
		else:
			proj_path = path.join(converted_path, "test")
		# Case for blank subj_id: default to "null"
		if len(subj_id).strip() < 1:
			subj_id = 'null'
		subj_folder = 'sub-' + subj_id
		
		ses_folder = 'ses-' + exam_no

		new_filename = 'sub-' + subj_id + '_ses-' + exam_no + '_series-' + scan_no + '_' + series_desc + ".7"
		
		target_path = str(path.join(proj_path, subj_folder, ses_folder, new_filename))		

		print("Adding transfer map to move_queue.txt")
		print(pfile + " >>> " + target_path)
		with open(move_queue_path, 'a') as queue:
			queue.write(pfile + ' ' + target_path + "\n")
		with open(changemap_path, 'a') as logfile:
			logfile.write(orig_filename + "\t" + new_filename + "\n")

		print("*******************************************************************")
