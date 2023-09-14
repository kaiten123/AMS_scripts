# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------
# This is ran at the beginning of each script to confirm we are not running these on RH8
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