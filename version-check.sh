# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------
# This is ran at the beginning of each script to confirm we are not running these on RH8
# mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/version-check.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/getDumps_v3.sh && chmod +x /mnt/tmp/diagnose/scripts/version-check.sh && /mnt/tmp/diagnose/scripts/version-check.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

# Linux version, not tested on RHEL 8
if [ -f /etc/redhat-release ]; then
    version=$(cat /etc/redhat-release)
    echo "Detected Linux Version: $version"
    if [[ "$version" == *"release 8"* ]]; then
        echo "Script not tested on Red Hat 8, exiting..."
        exit 1
    fi
fi