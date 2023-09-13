#!/bin/bash

# wget -q -O immutable.sh https://cdn1.frocdn.ch/EIu9RL7eUud6wPP.sh && chmod +x immutable.sh
# chattr +i 02-dispatcher.conf && chattr +i 10-mod_security.conf

folder_path="/etc/httpd/conf.modules.d"
log_file="$folder_path/processed_files.log"


if [ $# -eq 0 ]; then
    action="unset"  # Default action is "unset" if no parameters are passed
else
    action="$1"
fi

if [ "$action" = "set" ]; then
    # Step 1: Restore +i attribute to files listed in the log file
    if [ ! -f "$log_file" ]; then
        echo "No processed files found in the log."
        exit 1
    fi

    while IFS= read -r filename; do
        if [ "$filename" != "immutable.sh" ]; then
            chattr +i "$folder_path/$filename"
        fi
    done < "$log_file"

    echo "Restored +i attribute to files in the log."

    # Delete the log file
    rm "$log_file"

    echo "Deleted the processed files log."
elif [ "$action" = "unset" ]; then

    # Check if the log file exists
    if [ -f "$log_file" ]; then
        echo "The $log_file file already exists. Please manually delete it and run the script again."
        exit 1
    fi
    # Step 2: Remove +i attribute from files and update the log
    > "$log_file"  # Clear the log file

    for file in "$folder_path"/*; do
        if [ -f "$file" ] && [[ "$(basename "$file")" != "processed_files.log" ]] && [[ "$(basename "$file")" != "immutable.sh" ]]; then
            if [ -n "$(lsattr -d "$file" | awk '$1 ~ /-i/')" ]; then
                chattr -i "$file"
                echo "$(basename "$file")" >> "$log_file"
            fi
        fi
    done

    echo "Removed +i attribute from files in the folder and updated the log."
    cat "$log_file"
else
    echo "Unknown parameter: $action"
    exit 1
fi
