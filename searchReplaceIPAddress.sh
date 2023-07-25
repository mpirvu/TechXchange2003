#!/bin/bash

# Check if the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <old_ip_address> <new_ip_address>"
    exit 1
fi

old_ip="$1"
new_ip="$2"

# Find all .sh files in the current directory and its subdirectories
find . -type f -name "*.sh" | while read -r file; do
    # Call the replace_ip_in_file function for each .sh file
    sed -i "s/$old_ip/$new_ip/g" "$file"
done

