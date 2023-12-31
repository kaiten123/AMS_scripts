#!/bin/bash

# mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/immutable.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/immutable.sh && chmod +x /mnt/tmp/diagnose/scripts/immutable.sh && /mnt/tmp/diagnose/scripts/immutable.sh
# chattr +i /etc/httpd/conf.modules.d/02-dispatcher.conf && chattr +i /etc/httpd/conf.modules.d/10-mod_security.conf

# Checking Linux version, not tested on RHEL 8
mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/version-check.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/version-check.sh && chmod +x /mnt/tmp/diagnose/scripts/version-check.sh && /mnt/tmp/diagnose/scripts/version-check.sh

folder_path="/etc/httpd/conf.modules.d"
log_file="$folder_path/processed_files.log"

listImmutableFiles () {
    for file in "$folder_path"/*; do
        if [ -f "$file" ] && [[ "$(basename "$file")" != "processed_files.log" ]] && [[ "$(basename "$file")" != "immutable.sh" ]]; then
            if [ -n "$(lsattr "$file" | awk '$1 ~ /-i/')" ]; then
                echo "$(basename "$file")"
            fi
        fi
    done
}

removeImmutableAttributeAndLog () {
    for file in "$folder_path"/*; do
        if [ -f "$file" ] && [[ "$(basename "$file")" != "processed_files.log" ]] && [[ "$(basename "$file")" != "immutable.sh" ]]; then
            if [ -n "$(lsattr "$file" | awk '$1 ~ /-i/')" ]; then
                chattr -i "$file"
                echo "$(basename "$file")" >> "$log_file"
            fi
        fi
    done
}

if [ $# -eq 0 ]; then

    # Check if the log file exists
    if [ -f "$log_file" ]; then
        echo ""
        echo "The $log_file file already exists in $folder_path."
        echo ""
        echo "Exiting..."
        exit 1
    fi

    echo "Removing the +i attribute for files in $folder_path"
    echo "to restore the attributes run the same script with the set param"
    action="unset"  # Default action is "unset" if no parameters are passed
else
    # Check if the log file exists, stop if file not found
    if [ ! -f "$log_file" ]; then
        echo ""
        echo "Could not find $log_file in $folder_path"
        echo "Exiting..."
        exit 1
    fi

    action="$1"
fi

if [ "$action" = "set" ]; then
    while IFS= read -r filename; do
        if [ "$filename" != "immutable.sh" ]; then
            chattr +i "$folder_path/$filename"
        fi
    done < "$log_file"

    echo "Restored +i attribute to files in $folder_path:"
    listImmutableFiles

    # Delete the log file
    rm "$log_file"

    echo "Deleted the processed files log."
elif [ "$action" = "unset" ]; then

    # Step 2: Remove +i attribute from files and update the log
    > "$log_file"  # Clear the log file

    removeImmutableAttributeAndLog

    echo ""
    echo "Removed +i attribute from files in $folder_path and updated the log $log_file:"
    cat "$log_file"
else
    echo "Unknown parameter: $action"
    exit 1
fi
