#!/bin/bash

source ./common.sh

dnf module disable redis -y &>>$LOG_FILE
dnf module enable redis:7 -y &>>$LOG_FILE
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

# #update private address to listen all
# sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
# VALIDATE $? "Updating Redis listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Updating Redis configuration"
# #update protect mode to no
# sed -i -e 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
# VALIDATE $? "Updating Redis protected mode"

#start and enable redis
systemctl enable redis &>>$LOG_FILE
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting Redis Service"
