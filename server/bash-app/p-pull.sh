#!/bin/bash
# Organize files inside MRS_purgatory into their respective projects
# Runs after run.sh which handles rsync from MRI linux machine
pGlob=$(ls /MRI_DATA/nyspi/MRS_purgatory/*/*/*/*.7)
pFiles=(`echo $pGlob | tr ' ' ' '`)

echo -e "\nOrganizing files into appropriate project folders (derivatives/MRS)"
for pFile in "${pFiles[@]}"
do
    pathArr=(`echo $pFile | tr '/' ' '`)
    project=${pathArr[3]}
    subject=${pathArr[4]}
    exam=${pathArr[5]}
    fileName=${pathArr[6]}

    printf "\n\nProject: ${project} \nSubject: ${subject} \nExam: ${exam} \nFile: ${fileName} \n"
    
    dstParent=/MRI_DATA/nyspi/${project}/MRS
    dstFolder=${dstParent}/${subject}/${exam}
    dstFilePath=${dstFolder}/${fileName}
    echo -e "\n-Creating directories ${project}/MRS/${subject}/${exam}"
    mkdir -p ${dstFolder}
    echo -e "-Moving file"
    mv ${pFile} ${dstFilePath}
    echo ${subject}/${exam}/${fileName}>>/MRI_DATA/nyspi/MRS_purgatory/.rsyncignore     # prevent future syncs of moved files so data can remain on mri workstation
    echo -e "-Modifying permissions..."

#### PERMISSIONS ######################################################################
    # Pull primary user of group to create default user perms (better than the alternative root)
    groupFile=$(echo $(cat /etc/group))
    groupLines=(`echo $groupFile | tr ' ' ' ' `)
    for index in "${!groupLines[@]}";
    do
        if [[ "${groupLines[$index]}" = *"${project}"* ]];
        then
            echo -e "-Setting group ownership of newly created files and folders to ${project}"
            chown -vcRL :${project} ${dstParent}
            find ${dstParent} -type d -exec chmod 755 {} \;  #> dev/null 2>&1
            find ${dstParent} -type f -exec chmod 644 {} \; #> dev/null 2>&1
            echo groupLine = ${groupLines[$index]}
            matchedLine=(`echo ${groupLines[$index]} | tr ':' ' '`)
            user=${matchedLine[3]}
            if [ ! -z "$user" ]; 
            then
                echo -e "-Setting user ownership to ${user}"
                chown -vcRL ${user} ${dstParent}
            else
                echo -e "! No users assigned to group ${group}. User owner will remain as root"
            fi
        fi
    done
   
    
done

echo -e "-Cleaning up empty source directories: /MRI_DATA/nyspi/MRS_purgatory/*"    #${project}/${subject}
find /MRI_DATA/nyspi/MRS_purgatory/* -empty -type d -delete
