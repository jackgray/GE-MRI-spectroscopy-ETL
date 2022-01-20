from os import mkdir, path, makedirs
from shutil import move
from glob import glob
import matlab.engine
import io

eng = matlab.engine.start_matlab()
out = io.StringIO()
err = io.StringIO()

pfiles = glob('/home/sdc/data/rawdata/*.7')

for pfile in pfiles:
    orig_filename = os.path.basename(pfile)
    proj_id, subj_id, exam_no, scan_no, series_desc = eng.extract_nyspi_headers(pfile,stdout=out,stderr=err)
    # Format MATLAB returns
    subj_id = subj_id.replace(" ", "").replace("_", "").replace("-","")
    series_desc = series_desc.replace(" ", "").replace("_", "-")
    
    print("\n\n\n*******************************************************************")
    print("\nPulled the following header info from ", orig_filename)
    print("Project ID: ", proj_id)
    print("Subj ID: ", subj_id)
    print("Exam #: ", exam_no)
    print("Scan #: ", scan_no)
    print("Series ID: ", series_desc)
    
    proj_path = path.join("/home/sdc/data/rawdata/converted", proj_id)
    makedirs(proj_id, exist_ok=True)
    
    filename = 'sub-' + subj_id + '_ses-' + exam_no + '_series-' + scan_no + '_' + series_desc
    
    target_path = path.join(proj_path, filename)
    
    with open(change_map.log, 'a') as logfile:
        logfile.write(orig_filename + "\t>>>\t" + filename)
    
    print(orig_filename + "\t>>>\t" + filename)
    print(pfile + "\t>>>\t" + target_path)
    
    print("*******************************************************************")

    
    