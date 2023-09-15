# One liner to restart AEM, trying to stop 3 times, trying to start 3 times
# mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/aem-restart.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-restart.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-restart.sh && /mnt/tmp/diagnose/scripts/aem-restart.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

# Checking Linux version, not tested on RHEL 8
mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/version-check.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/version-check.sh && chmod +x /mnt/tmp/diagnose/scripts/version-check.sh && /mnt/tmp/diagnose/scripts/version-check.sh

# stopping AEM with 3 retries
mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/aem-stop.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-stop.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-stop.sh && /mnt/tmp/diagnose/scripts/aem-stop.sh

#starting AEM  with 3 retries
mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/aem-start.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-start.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-start.sh && /mnt/tmp/diagnose/scripts/aem-start.sh
