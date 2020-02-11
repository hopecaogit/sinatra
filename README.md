# Deploy Trent's Simple Sinatra App to AWS

This project is to deploy Trent's Simple Sinatra App using AWS cli.
It uses a single EC2 to host this application which is available on port 80
This deployment is tested in Mac OS and Ubuntu.

## Prerequisite
- AWS Account
- An AWS user with EC2 Full access permission
- Install AWS cli
- Configure AWS cli. This deploy using cli default profile. To use a different
  profile, please add --profile to cli in shell scripts, and to replace
  the AMI ID in deploy.sh with an Ubuntu AMI ID from the region you intend to deploy.

## Files  
All these shell scripts take one parameter, resource filename.
This resource file holds instance id, security group id, keypair name and
private key file name.
The scripts creates resources in Sydney region. To use a different region,
please change deploy_region variable in all three shell scripts.
- deploy.sh
  This script creates a security group, a key pair for SSH and a EC2 to host
  the application. The security group opens port 80 to everywhere, port 22 to
  the public IP of the user.

- cleanup.sh
  This script deletes the all the resources created by deploy.sh and
  the private key file in the working directory. It takes about 30 seconds
  to delete all the resources.

- check_ec2_public_dns.sh
  This script runs after deploy.sh to check EC2 public DNS name and instance status.

- bootstrap
  This is the bootstrap script for the EC2. It installs Ruby, clone Simple Sinatra
  app, run the app listening to port 9292, redirect port 80 to port 9292 and enable
  firewall opening only port 9292 and 22.

## Instructions
- Create a working directory
- git clone this repository to working directory
- set all shell scripts to executable
- Steps
  1. Run deploy.sh [resourcefilename]
  2. Run check_ec2_public_dns.sh [resourcefilename]
     When EC2 status is running, wait for approximately a minute to let bootstrap
     to complete. Get the public DNS name from the output. Two options to check
     curl [publicdnsname]
     Go to a brower, http://[publicdnsname]

     Both shows "Hello World!"
  3. Run cleanup.sh [resourcefilename]  
