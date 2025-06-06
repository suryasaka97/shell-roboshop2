#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01659ab712a1c0efe"
ZONE_ID="Z0223797DGGO4EOPINIX"
DOMAIN_NAME="anantya.space"
Type="t2.micro"

##To create multiple instances at one go
Instance=("catlouge" "users" "frontend" "mysql" "mongodb" "rabitnq" "redis" "dispatch" "payment" "shipping" "cart")


for instance in ${Instance[@]}
do
    Instance_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $Type \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text)
   
    if [ $instance != frontend ]
    then 
         ip=$(aws ec2 describe-instances --instance-ids $Instance_ID \
        --query "Reservations[0].Instances[0].PrivateIpAddress" \
        --output text)
    else
        ip=$(aws ec2 describe-instances --instance-ids $Instance_ID \
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text)
    fi

    echo "$instance : $ip" 

done
 

