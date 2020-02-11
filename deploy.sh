#!/bin/bash
#first parameter of this script is resource filename
if [ $# -eq 0 ]; then
    echo "Please provide resource filename as first parameter"
    exit 1
fi

deploy_region="ap-southeast-2"
resr_file=${1}
keypair_file=sinatra.pem
keypair_name=SinatraKeyPair
# get public IP address for SSH
myip=`curl -s https://ipinfo.io/ip`

#get ubuntu AMI ID depending on deploy_region
image_id=`aws ec2 describe-images --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200112" \
    --region ${deploy_region} | jq -r '.Images[0].ImageId'`

#file to contain resouce ids deployed for future cleanup
touch ${resr_file}

# create resources to deploy rail application
# EC2, security group and keypair

#create security group
sg_group_id=`aws ec2 create-security-group --group-name RailAppSG \
             --description "Security group for rail app" --region ${deploy_region} \
             | jq -r ".GroupId"`
echo "sg_group_id="${sg_group_id} >> ${resr_file}
aws ec2 authorize-security-group-ingress --group-id ${sg_group_id} \
--protocol tcp --port 22 --cidr ${myip}/32
aws ec2 authorize-security-group-ingress --group-id ${sg_group_id} \
--protocol tcp --port 80 --cidr 0.0.0.0/0

#create keypair
aws ec2 create-key-pair --key-name ${keypair_name} --region ${deploy_region} | jq -r '.KeyMaterial' > ${keypair_file}
chmod 400 ${keypair_file}
echo "keypair_name="${keypair_name} >> ${resr_file}
echo "keypair_file="${keypair_file} >> ${resr_file}

#create EC2, deploy app
inst_id=`aws ec2 run-instances --image-id ${image_id} --count 1 \
--instance-type t2.micro  --key-name ${keypair_name} \
 --security-group-ids ${sg_group_id} \
--user-data file://bootstrap --region ${deploy_region} | jq -r '.Instances[0].InstanceId'`
echo "inst_id="${inst_id} >> ${resr_file}

echo "resources are deployed"
