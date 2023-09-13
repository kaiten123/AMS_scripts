# One liner to start AEM with retries
# mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/aem-start.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-start.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-start.sh && /mnt/tmp/diagnose/scripts/aem-start.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

echo "Starting AEM, trying 3 times..."
attempt=1

while [ $attempt -le 3 ]; do
    echo "Attempt $attempt to start AEM..."
    service cq5 start
    sleep 5 # Wait a bit after trying to start before re-checking
    CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');

    if [[ "$CQ5_PID" =~ ^[0-9]+$ ]]; then
        echo "AEM successfully started with PID: $CQ5_PID"
        break
    elif [[ -z "$CQ5_PID" ]]; then
        echo "Starting AEM failed, no PID detected. Tried $attempt times."
        if [ $attempt -lt 3 ]; then
            sleep 5 # Wait a bit before trying again, but only if it wasn't the last attempt
        fi
    else
        echo "Unexpected error. Trying again..."
        sleep 5 # Give a pause before the next attempt even if unexpected error
    fi
    ((attempt++))
done

if [ $attempt -gt 3 ]; then
    echo "Failed to start AEM after 3 attempts."
fi