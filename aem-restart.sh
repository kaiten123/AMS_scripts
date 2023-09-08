# One liner to restart AEM
# mkdir -p /mnt/tmp/diagnose/scripts && wget -O /mnt/tmp/diagnose/scripts/aem-restart.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-restart.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-restart.sh && /mnt/tmp/diagnose/scripts/aem-restart.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

# stopping AEM with 3 retries
mkdir -p /mnt/tmp/diagnose/scripts && wget -O /mnt/tmp/diagnose/scripts/aem-stop.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-stop.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-stop.sh && /mnt/tmp/diagnose/scripts/aem-stop.sh

echo "Starting AEM."
service cq5 start

CQ5_PID=$(echo "$(service cq5 status)" | grep -oP 'PID: \K\d+');
if [[ -z "$CQ5_PID" ]]; then
    echo "AEM is still stopped, please start it manually."
else [[ "$CQ5_PID" =~ ^[0-9]+$ ]]; then
    echo "AEM started."
fi