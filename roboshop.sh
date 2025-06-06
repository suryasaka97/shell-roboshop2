#! /bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01659ab712a1c0efe"
ZONE_ID="Z0223797DGGO4EOPINIX"
DOMAIN_NAME="anantya.space"
Instance_type="t2.micro"

aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $Instance_type \
  --security-group-ids $SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=frontend}]' \
  --output json
