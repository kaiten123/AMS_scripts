# One liner to stop AEM with retries
# mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/aem-stop.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-stop.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-stop.sh && /mnt/tmp/diagnose/scripts/aem-stop.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

# Checking Linux version, not tested on RHEL 8
mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/version-check.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/version-check.sh && chmod +x /mnt/tmp/diagnose/scripts/version-check.sh && /mnt/tmp/diagnose/scripts/version-check.sh

CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');
attempt=1

while [ $attempt -le 3 ]; do
    echo "Attempt $attempt to stop process..."
    systemctl stop cq5
    sleep 5 # Wait a bit after trying to stop before re-checking
    CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');

    if [[ -z "$CQ5_PID" ]]; then
        echo "AEM successfully stopped - could not find process"
        break
    elif [[ "$CQ5_PID" =~ ^[0-9]+$ ]]; then
        echo "Stopping AEM failed, PID detected: $CQ5_PID. Tried $attempt times."
        if [ $attempt -lt 3 ]; then
            sleep 5 # Wait a bit before trying again, but only if it wasn't the last attempt
        fi
    else
        echo "Unexpected error. Assuming the process is not up."
        sleep 5 # Give a pause before the next attempt even if unexpected error
    fi
    ((attempt++))
done

if [ $attempt -gt 3 ]; then
    echo "Failed to stop AEM after 3 attempts."
fi


if [ $attempt -gt 3 ]; then
    echo "Restart failed after $attempt attempts. Killing process $CQ5_PID."
    kill -9 $CQ5_PID
    servicestop
fi
echo ""
