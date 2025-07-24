#! /bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01659ab712a1c0efe"
ZONE_ID="Z0223797DGGO4EOPINIX"
DOMAIN_NAME="anantya.space"
Instance_type="t2.micro"


##Basic script to create aws instance###
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $Instance_type \
  --security-group-ids $SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=frontend}]' \
  --output json   ###Tags are used to provide names### #And here Output is in JSON#

##Command used to see the particular Instance Details##
aws ec2 describe-instances \
  --instance-ids i-0cd1d9c1133444f49 

##Command to get Public IP address using query from a instance
aws ec2 describe-instances --instance-ids i-0cd1d9c1133444f49 \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text

##Command to get instance_ID
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \  # Replace with your AMI ID
  --instance-type t2.micro \
  --key-name my-keypair \             # Replace with your key name
  --security-group-ids sg-12345678 \  # Replace with your SG ID
  --subnet-id subnet-12345678 \       # Replace with your subnet ID
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=myServer1}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

##command to get Ip_address
INSTANCE_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \  ##$Instance_ID is variable used fom above command
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Public IP Address: $INSTANCE_IP"

## Command to create or update DNS Records ##
#create, delete

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Creating and updating record set for cognito endpoint"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$instance'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 10
        ,"ResourceRecords"  : [{
            "Value"         : "'$ip'"
        }]
      }
    }]
  }'


