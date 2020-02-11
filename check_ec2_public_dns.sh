#!/bin/bash
#first parameter of this script is resource filename
if [ $# -eq 0 ]; then
    echo "Please provide resource filename as first parameter"
    exit 1
fi

deploy_region="ap-southeast-2"
resr_file=${1}

source ${resr_file}

aws ec2 describe-instances --instance-ids ${inst_id} --region ${deploy_region} \
    --query 'Reservations[*].Instances[0].{PublicDnsName:PublicDnsName,Status:State.Name,PublicIpAddress:PublicIpAddress}' \
    --output table
