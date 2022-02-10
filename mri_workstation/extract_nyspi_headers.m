% Belongs to python script of the same name
% Triggered by python script to run for each file
% in the specified path, and will return the desired 
% header info for file renamiing and sorting 

function [proj_id, subj_id, exam_no, scan_no, series_desc] = extract_nyspi_headers(pfile)

    header = read_MR_headers(pfile) ;
    proj_id = string(header.exam.ex_desc) ;
    subj_id = string(char(header.exam.patnameff)) ; 
    exam_no = string(header.series.se_exno) ;
    scan_no = string(header.series.se_no) ;
    series_desc = char(header.series.se_desc) ;

end