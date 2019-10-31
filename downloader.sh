database=waitinglist

getTask() {
    cat "${database}" | while read line
    do
        id=`echo $line | tr "?&" "\n\n" | grep "^v=" | cut -d "=" -f 2`
        task="${id}"
        taskLock="${task}.lock"
        if [ ! -f "${taskLock}" ]; then
            touch "${taskLock}"
            echo "${task}"
            return
        fi
    done
}

removeTask() {
    task=$1
    if [ -z "${task}" ]; then
        echo "Error! No task to clean up"
        return
    fi
    taskLock="${task}.lock"
    echo "${taskLock} to delete"
    /bin/rm -rf "${taskLock}"
    grep -v "${task}" "${database}" > "${database}.new"; mv "${database}.new" "${database}"
    echo "remaining list:"
    cat ${database}
}

getDownloadUrl() {
    task=$1
    if [ -z "${task}" ]; then
        echo "Error! No task for URL"
        return
    fi
    url=`grep "${task}" "${database}"`
    if [ -z "${url}" ]; then
        echo "Error! No URL found for task ${task}"
        return
    fi
    echo "Found URL for task ${task}: ${url}"
}

downloadTask() {
    task=$1
    if [ -z "${task}" ]; then
        echo "Error! No task for download"
        return
    fi
    getDownloadUrl "${task}"
    if [ -z "${url}" ]; then
        return "Error! No URL for download"
        return
    fi
    echo "Ready to download ${url}"

    id=`echo "${url}" | tr "?&" "\n\n" | grep "^v=" | cut -d "=" -f 2`
    logFile="${id}".log
    youtube-dl --proxy http://proxy.vmware.com:3128 -f "${format:-22}" --write-thumbnail --write-sub --embed-subs --sub-lang en_US,en_US,en "${url}" > "${logFile}"
    thumbnail=`cat "${logFile}" | sed -n 's/.*Writing\ thumbnail.*:\ \(.*\)/\1/p'`
    video=`cat "${logFile}" | sed -n 's/.*Destination:\ \(.*\)/\1/p'`
    extension="${video##*.}"
    tempFile="${id}"."${extension}"
    echo "${tempFile}"
    /bin/rm -rf "${logFile}"
    ffmpeg -i "${video}" -i "${thumbnail}" -map 0 -map 1 -c copy -c:v:1 png -disposition:v:1 attached_pic -y "${tempFile}"; /bin/rm -rf "${thumbnail}"; mv "${tempFile}" "${video}"

    echo "Successfully downloaded ${url}"
    removeTask "${task}"
}

while true
do
    task=$(getTask)
    if [ ! -z "${task}" ]; then
        echo "Found taks to download ${task}"
        downloadTask "${task}"
    else
        echo "No task to download"
        exit 0
    fi
done
