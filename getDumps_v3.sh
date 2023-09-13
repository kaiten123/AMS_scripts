#!/bin/bash

# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------
# One liner to get the debug info (default params, NO AEM restart)
# mkdir -p /mnt/tmp/diagnose/scripts && wget -O /mnt/tmp/diagnose/scripts/getDumps.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/getDumps_v3.sh && chmod +x /mnt/tmp/diagnose/scripts/getDumps.sh && /mnt/tmp/diagnose/scripts/getDumps.sh --restartAEM=false
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------
# USE WITH CAUTION: One liner to get the debug info (default params, WITH AEM restart)
# mkdir -p /mnt/tmp/diagnose/scripts && wget -O /mnt/tmp/diagnose/scripts/getDumps.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/getDumps_v3.sh && chmod +x /mnt/tmp/diagnose/scripts/getDumps.sh && /mnt/tmp/diagnose/scripts/getDumps.sh --restartAEM=true
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------


# Description:
# This script collects diagnostic information for AEM.
# It takes various parameters to customize its behavior, such as thread count,
# thread delay for the thread dump, and the AEM restart option.

# Usage:
# ./getDumps.sh [--destination folder] [--threadCount X] [--threadDelay X] [--restartAEM]

# Parameters:
#   --destination: Specifies the destination folder for diagnostic data.
#                  Default: /mnt/tmp/diagnose
#                  Note: The destination path must be an absolute path.
#
#   --threadCount: Specifies the number of thread dumps to collect.
#                  Default: 10
#                  Note: The thread count must be a positive integer.
#
#   --threadDelay: Specifies the delay between thread dumps in seconds.
#                  Default: 5
#                  Note: The thread delay must be a positive number.
#
#   --restartAEM:  If set to 'true', the script will attempt to restart the AEM
#                  service after collecting diagnostic data. If restarting fails,
#                  it will make up to 3 attempts and then kill the AEM process.
#                  Default: false

# Example Usage:
# ./getDumps.sh --destination=/home/mtica --threadCount=2 --threadDelay=3 --restartAEM=false

# Logic:
# - The script accepts parameters to customize the data collection behavior.
# - It creates a timestamped folder in the destination directory to store data.
# - Thread dumps and process information are archived in zip files.
# - A heap dump is collected and zipped.
# - The script can optionally restart the AEM service, with retries and process checks.

# For ideas and bugs, reach out to Mihai Tica (mtica@adobe.com)



# Linux version, not tested on RHEL 8
if [ -f /etc/redhat-release ]; then
    version=$(cat /etc/redhat-release)
    echo "Detected Linux Version: $version"
    if [[ "$version" == *"release 8"* ]]; then
        echo "Script not tested on Red Hat 8, exiting..."
        exit 1
    fi
fi

# Function to print text in red color
print_red() {
    echo -e "\033[1;31m$1\033[0m"
}

# Default values
DEFAULT_DESTINATION="/mnt/tmp/diagnose"
DEFAULT_THREAD_COUNT=10
DEFAULT_THREAD_DELAY=5
DEFAULT_RESTART_AEM=false

# Constants
ORIGINAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%d-%m-%Y-%H.%M.%S)
CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');
threadUser="crx"

if [ -z "$CQ5_PID" ]
then
    echo ""
    print_red "\$CQ5_PID is empty, AEM not running on this machine."
    echo ""
    exit 1
fi

# checking if the crx user exists on the instance
if ! id "$threadUser" &>/dev/null; then
    echo ""
    print_red "User $threadUser does not exist on instance ($HOSTNAME), exiting..."
    echo ""
    exit 1
fi

# Set default values
destination="$DEFAULT_DESTINATION"
threadCount="$DEFAULT_THREAD_COUNT"
threadDelay="$DEFAULT_THREAD_DELAY"
restartAEM="$DEFAULT_RESTART_AEM"

# Parse command-line options
for arg in "$@"; do
    case "$arg" in
        --destination=*)
            destination="${arg#*=}"
            ;;
        --threadCount=*)
            threadCount="${arg#*=}"
            if ! [[ "$threadCount" =~ ^[0-20]+$ ]]; then
                echo "Invalid threadCount value: $threadCount, should be 0-20"
                exit 1
            fi
            ;;
        --threadDelay=*)
            threadDelay="${arg#*=}"
            if ! [[ "$threadDelay" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                echo "Invalid threadDelay value: $threadDelay, should be 0-9"
                exit 1
            fi
            ;;
        --restartAEM=*)
            restartAEM="${arg#*=}"
            if ! [[ "$restartAEM" =~ ^(true|false)$ ]]; then
                echo "Invalid restartAEM value: $restartAEM, should be either true or false"
                exit 1
            fi
            ;;
        *)
            echo "Unrecognized parameter: $arg"
            exit 1
            ;;
    esac
done

# Create folders
folderName="$HOSTNAME-$TIMESTAMP"
mkdir -p "$destination/$folderName"
mkdir -p "/mnt/tmp/scripts"

if [ "$restartAEM" = true ]; then
    print_red "╔═══════════════════════════════════════════════════╗"
    print_red "║                                                   ║"
    print_red "║                      WARNING:                     ║"
    print_red "║                                                   ║"
    print_red "║  AEM restart will be triggered at the end of the  ║"
    print_red "║  dump collection. If you do not want the restart  ║"
    print_red "║  to happen, end the script NOW.                   ║"
    print_red "║                                                   ║"
    print_red "╚═══════════════════════════════════════════════════╝"
fi

echo ""
echo "--->>> Running with params:"
echo ""
echo "log folder: $destination/$folderName"
echo "threadCount: $threadCount"
echo "threadDelay: $threadDelay"
if [ "$restartAEM" = true ]; then
    print_red "restart AEM: $restartAEM"
else
    echo "restart AEM: $restartAEM"
fi
echo ""

# Change directory
cd "$destination/$folderName" || {
    echo "The folder $destination/$folderName does not exist, exiting at line $LINENO"
    exit 1
}

# take thread dump
echo "--->>> Taking thread and heap dumps"

while [ $threadCount -gt 0 ]
do
    top -H -b -n1 -p $CQ5_PID > top.$CQ5_PID.$(date +%H%M%S.%N) &
    sudo -u $threadUser /usr/java/latest/bin/jstack -l $CQ5_PID >jstack.$CQ5_PID.$(date +%H%M%S.%N)
    sleep $threadDelay
    let threadCount--
    echo -n "."
done

jstack_log="thread-$HOSTNAME-$TIMESTAMP.log"
echo ""
echo "--->>> Running: sudo -u $threadUser /usr/java/latest/bin/jstack '$CQ5_PID' >> '$jstack_log'"
sudo -u $threadUser /usr/java/latest/bin/jstack "$CQ5_PID" >> "$jstack_log"

# take heap dump
heap_dump="heapdump-$TIMESTAMP.hprof"
sudo chown -R $threadUser:$threadUser $destination
echo "--->>> Running: sudo -u $threadUser /usr/java/latest/bin/jcmd '$CQ5_PID' GC.heap_dump '$destination/$folderName/$heap_dump'"
sudo -u $threadUser /usr/java/latest/bin/jcmd "$CQ5_PID" GC.heap_dump "$destination/$folderName/$heap_dump"

# fixing permissions for the heap dump file so downloading via amstool works
sudo chmod 644 $destination/$folderName/$heap_dump

echo "--->>> Zipping files"
zip -q ../jstack-"$TIMESTAMP".zip "$jstack_log"
zip -q ../processes-"$TIMESTAMP".zip top*
# using watch so the connection does not close if zipping takes too long
(
    (sleep 1 && while pgrep zip > /dev/null; do echo -n "."; sleep 1; done) &
    zip -q ../heap_dump-"$TIMESTAMP".zip "$heap_dump"
)

# move zips to diagnose folder
mv ../jstack-"$TIMESTAMP".zip .
mv ../processes-"$TIMESTAMP".zip .
mv ../heap_dump-"$TIMESTAMP".zip .

# cleanup other files, keep only .zip
find . -type f ! -name "*.zip" -exec rm -f {} +

# Return to initial folder
cd "$ORIGINAL_DIR"

# AEM restart mechanism
echo ""
if [ "$restartAEM" = true ]; then
    echo ""
    echo "Starting AEM."
    mkdir -p /mnt/tmp/diagnose/scripts && wget -O /mnt/tmp/diagnose/scripts/aem-restart.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-restart.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-restart.sh && /mnt/tmp/diagnose/scripts/aem-restart.sh
fi

# showing download links
echo ""
echo ""
echo "--->>> Download archives:"
echo ""
echo "Thread dump:"
echo "amstool scp $HOSTNAME $destination/$folderName/jstack-$TIMESTAMP.zip ~/Downloads/"
echo ""
echo "Processes list:"
echo "amstool scp $HOSTNAME $destination/$folderName/processes-$TIMESTAMP.zip ~/Downloads/"
echo ""
echo "Heap dump:"
echo "amstool scp $HOSTNAME $destination/$folderName/heap_dump-$TIMESTAMP.zip ~/Downloads/"
echo ""
echo "Thread and heap dumps for $HOSTNAME collected at:"
echo "$destination/$folderName"