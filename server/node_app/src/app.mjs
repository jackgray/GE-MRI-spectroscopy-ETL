#!/usr/bin/env zx

import { $, chalk, fs } from "zx"
import { join, format } from 'path'
import { fdir } from "fdir"
import { appendFile } from 'fs';
// import arsync from "./arsync.mjs"
import fixPerms from "./chowmod.mjs"

export default () => {
    // path definitions
    let projectsDir = join('/MRI_DATA', 'nyspi');
    let mrsPurgatory = join(projectsDir, 'MRS_purgatory');
    let rsyncIgnorePath = '/MRI_DATA/nyspi/MRS_purgatory/.rsyncignore';
    let rawdataPath = '/home/sdc/data/rawdata'
    let converted = rawdataPath + '/converted'
    let queueFile = format({ dir: rawdataPath, base: 'move_queue.txt' })

    // Index all files in MRS purgatory
    const crawler = new fdir()
        .withFullPaths()
        .crawl(mrsPurgatory)
        // async/await promise is significantly more efficient
    crawler.withPromise().then((mrsFiles) => {
        console.log(mrsFiles)
        // If files exist, attempt to organize them
        if (mrsFiles.length > 0) {
            let added = [] // initialize queue for adding moved files to .rsyncignore
            for (let file of mrsFiles) {
                if (file.endsWith('.7')) {      // ensure only .7 files are organized
                    let splitFilePath = file.split('/')
                    let project = splitFilePath[4]
                    let subname = splitFilePath[5]; if (subname == 'sub-') { subname = 'sub-test' }
                    let sesname = splitFilePath[6]
                    let fileName = splitFilePath[7]
                    console.log(
                        "\n****************************************",
                        "\nSorting p-file for project: ", project,
                        "\nSubject: ", subname, 
                        "\nExam #: ", sesname,
                        "\nFile: ", fileName,
                    )
                    let oldSubjectPath = join(mrsPurgatory, project, subname)
                    let dstParent = join(projectsDir, project, 'MRS', subname, sesname)
                    
                    // Define async functions

                    // Set up destination directory structure                        
                    const makeDirs = async () => { 
                        console.log("\nCreating directories for destination path \n", dstParent)
                        await $`mkdir --parents ${dstParent}`
                    }
                    // Move files
                    const moveFiles = async () => { 
                        console.log("\nMoving file ", fileName, "to ", dstParent)
                        await $`mv -u ${file} ${dstParent}`
                        added.push(file)    // keep track of what is organized and add to .rsyncignore files to prevent redundant syncing
                    }

                    // Delete emptied folders -- handled outside of container
                    const cleanUp = async () => { 
                        console.log("Cleaning up old directory stucture ", oldSubjectPath)
                        await $`find ${oldSubjectPath} -empty -type d -delete`
                    }

                    if (project == 'millqsd') {
                        makeDirs().then(() => {
                            moveFiles().withPromise().then(() => {
                                fixPerms(dstParent).withPromise().then(() => {
                                    console.log('\nDone\n')
                                })
        
                            });
                           
                        })
                         
                    }
                    
                } 
            }

            // Add record of moved files to .rsyncignore
            if (added.length > 0 ) {
                appendFile(rsyncIgnorePath, added, function (err) {
                    if (err) throw err;
                    console.log("Sync log updated.")
                })
            }
        // if globbed files are not > 0, exit gracefully
        } else {
            console.log("\nNo files found in MRS_purgatory. All projects are up to date.\n\n")
            }
    })
}