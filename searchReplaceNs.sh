#!/bin/bash

old_namespace="sccproject-[Your initial]"
new_namespace=$CURRENT_NS

selected_files=$(find ./Knative -type f -name "*.yaml")
changes=0

for file in "${selected_files[@]}"; do
    sed -i "s/$old_namespace/$new_namespace/g" "$file"
    changes=$((changes + 1))
done
echo "Changed $changes files to replace $old_namespace with $new_namespace"
