#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
REGION="us-east-1"
SG_ID="sg-093dd9ce6f294bb69"

for instance in $@; 
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --region $REGION \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --count 1 \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    #Get public  and Private IPs
    if [ $instance != "frontend" ]; then
        echo "Waiting for 2 mins for instance to be in running state"
        sleep 10
        Private_IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --region $REGION \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
        echo "$instance Private IP: $Private_IP"
    else
        echo "Waiting for 2 mins for instance to be in running state"
        sleep 10
        Public_IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --region $REGION \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        echo "$instance Public IP: $Public_IP"
    fi