# One liner to get the OTC on both pub or authors
# mkdir -p /mnt/tmp/diagnose/scripts && wget -O /mnt/tmp/diagnose/scripts/aem-stop.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-stop.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-stop.sh && /mnt/tmp/diagnose/scripts/aem-stop.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');
attempt=1
while [ $attempt -le 3 ]; do
    echo "Attempt $attempt to check process status..."
    service cq5 stop
    CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');
    sleep 5 # Wait a bit before re-checking
    if [ -z "$CQ5_PID" ] 
    then
        echo "AEM stopped - could not find process $CQ5_PID"
        break
    else
        echo "Stopping AEM failed"
        sleep 5 # Wait a bit before re-checking
    fi
    ((attempt++))
done

if [ $attempt -gt 3 ]; then
    echo "Restart failed after $attempt attempts. Killing process $CQ5_PID."
    kill -9 $CQ5_PID
fi
echo ""