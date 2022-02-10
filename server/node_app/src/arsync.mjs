import rsync from "rsyncwrapper"

const asyncRrsync = () => {
    rsync({
        src: "/home/sdc/data/rawdata/converted/*.7",
        dest: "/MRI_DATA/nyspi/MRS_purgatory",
        ssh: true,
        recursive: true,
        sshCmdArgs: ["-o StrictHostKeyChecking=no"],
        compareMode: "sizeOnly",
        args: ['-havzPrti', '--itemize-changes', '--stats']
    },
    function(error, stdout, stderr, cmd) {
        if (error) {
            console.log(error)
        } else {
            console.log("Finished updating p-files.")
        }
    })
}

export default asyncRsync;


   // rsync MRS data from MRI workstation asyncronously
    // const asyncRsync = async () => {
    //     try {
    //         await $`ionice -c3 rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' sdc@156.111.80.32:${converted} ${mrsPurgatory}`
    //     } catch (err) {
    //         console.log(err)
    //         console.error(err)
    //     }
    // }    
    // asyncRsync().withPromise

    // const updateFiles = async () => {
    //     await $`scp -F /etc/ssh/ssh_config sdc:${queueFile} ${mrsPurgatory}`;
    //     await $`cat ${MRS_purgatory}/move_queue.txt`
    // }
    // updateFiles().withPromise