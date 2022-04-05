import { $ } from "zx"

const fixPerms = parentDir => {
    let project = parentDir.split('/')[2]   // pull project id from path 
    let groupFile = $`echo $(cat /etc/group)`     // read from group file to retrieve proper permissions info
    let groupLines = groupFile.toString().split(' ')    // create index
    let groupMatch = groupLines.find(groupLine => groupLine.startsWith(project));   // Match against project id
        // Try in stages: group then user
            try {
                let groupName = groupMatch.split(':')[0]
                $`find ${parentDir} -type d -exec chmod 755 {}`   // 755 for directories only
                $`find ${parentDir} -type f -exec chmod 644 {}`   // 644 for files
                $`find ${parentDir} -exec chgrp ${groupName} {}`
                $`chown -R :${groupName} ${parentDir}`
            // If group succeeds, try user
                try {
                    primeUser = groupMatch.split(':')[3]
                    console.log("Making group \'", groupName, "\' and user \'", 
                        primeUser, "\' owner for added files and folders.")
                } catch {
                    console.log("Making group \'", groupName, "\' owner for added files and folders.")
                    console.log("No username associated with this group was detected -- \
                    leaving user permissions alone.")
                }
        // If no group, there can't be a user
            } catch {
                console.log('No matching group in system for project \'', project,
                 '\'\nUnable to modify permissions for this project. Most likely, \
                 the project description was entered at the console improperly. \
                 Correct the name and the next time this script runs it should work :) ')
            }
}

export default fixPerms;