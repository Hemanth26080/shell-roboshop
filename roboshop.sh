#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-093dd9ce6f294bb69"
ZONE_ID="Z09571432H0XSZWLPQGY5"
DOMAIN_NAME="phemanth.in"

for instance in $@; 
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    #Get public  and Private IPs
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
            RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
            RECORD_NAME="$DOMAIN_NAME"
    fi
    echo "$instance IP: $IP"

    aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Updating record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '

done
