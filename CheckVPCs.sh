#!/bin/bash
if [ $# -gt 0 ]; then

    for REGION in $@; do
    echo "Getting VPC details for : ${REGION}"
    #VPCS=$(aws ec2 describe-vpcs --region "$REGION" --query "Vpcs[].VpcId" --output text 2>/dev/null)
    aws ec2 describe-vpcs --region "$REGION" &>/dev/null
        if [ $? -eq 0 ]; then
            aws ec2 describe-vpcs --region "$REGION" --query "Vpcs[*].[Tags[?Key=='Name'].Value | [0],VpcId, CidrBlock]" --output table
        else
            echo "Invalid Region: ${REGION}"
            echo "###################"
            #echo "Breaking Loop at ${REGION}"
            #break
            echo "Exiting Loop at ${REGION}"
            exit 99
        fi
    done
else
    echo "Provide at Least one region to check"
fi
