#!/bin/bash

source ./common.sh
app_name=dispatch

check_root
app_setup

#install dependencies
dnf install golang -y &>>$LOG_FILE
VALIDATE $? "Installing Golang"
cd /app 
go mod init dispatch
go get 
go build
VALIDATE $? "Building $app_name application"


systemd_setup
app_restart
print_total_time