#!/bin/bash

# Exit immediately on error, treat unset variables as errors, catch pipeline failures
set -euo pipefail

delete_volumes() {
    if [ $# -eq 0 ]; then
        echo "ERROR: Please provide at least one region to check." >&2
        return 1
    fi

    # Loop through each region passed to the function
    for REGION in "$@"; do
        echo "=== [$(date +'%Y-%m-%d %H:%M:%S')] Scanning region: ${REGION} ==="

        # Production optimization: Fetch ID, Size, and State in ONE single API call.
        # Format output as: "VolumeId Size State" separated by tabs
        local volume_list
        volume_list=$(aws ec2 describe-volumes --region "${REGION}" \
            --query "Volumes[*].[VolumeId, Size, State]" \
            --output text 2>/dev/null) || {
                echo "ERROR: Failed to connect to AWS in region ${REGION}. Skipping." >&2
                continue
            }

        # If the string is empty, no volumes exist in this region
        if [ -z "$volume_list" ]; then
            echo "No volumes found in ${REGION}."
            continue
        fi

        # Process the list line by line safely using standard input reading
        echo "$volume_list" | while read -r vol size state; do
            # Safeguard: Skip if data parsing somehow resulted in empty strings
            if [ -z "$vol" ] || [ -z "$size" ] || [ -z "$state" ]; then
                continue
            fi

            # Check volume criteria
            if [ "$state" == "in-use" ]; then
                echo "  -> Skip: $vol is attached to an instance."
            elif [ "$size" -gt 5 ]; then
                echo "  -> Skip: $vol is larger than 5GB (${size}GB)."
            else
                # Production Warning & Execution
                echo "  ⚠️ ACTION: Deleting Volume $vol (${size}GB) from ${REGION}..."
                
                # To make this a 100% safe dry-run first, add '--dry-run' below.
                # Remove '--dry-run' only when you are completely ready to delete.
                #if ! aws ec2 delete-volume --volume-id "$vol" --region "${REGION}" --dry-run 2>&1; then
                if ! aws ec2 delete-volume --volume-id "$vol" --region "${REGION}"; then
                    echo "   ERROR: Failed to delete volume $vol" >&2
                else
                    echo "   Success: Volume $vol deleted."
                fi
            fi    
        done
    done
}

# Example of calling the function safely in production
delete_volumes "us-east-1" "us-west-2"