#!/bin/bash
#first parameter of this script is resource filename
if [ $# -eq 0 ]; then
    echo "Please provide resource filename as first parameter"
    exit 1
fi

deploy_region="ap-southeast-2"
resr_file=${1}

source ${resr_file}

aws ec2 terminate-instances --instance-ids ${inst_id} --region ${deploy_region}
sleep 10s
inst_status=`aws ec2 describe-instances --instance-ids ${inst_id} --region ${deploy_region} \
    --query 'Reservations[*].Instances[0].{Status:State.Name}' \
    --output text`

while true
do
  if [ ${inst_status} == "terminated" ]
  then
    aws ec2 delete-security-group --group-id ${sg_group_id} --region ${deploy_region}
    aws ec2 delete-key-pair --key-name ${keypair_name} --region ${deploy_region}
    break
  else
    sleep 10s
    inst_status=`aws ec2 describe-instances --instance-ids ${inst_id} --region ${deploy_region} \
        --query 'Reservations[*].Instances[0].{Status:State.Name}' \
        --output text`
  fi
done

rm ${resr_file}
rm -f ${keypair_file}

echo "resources cleaned"
