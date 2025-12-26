#!/bin/bash

source ./common.sh
app_name=mysql

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld  
VALIDATE $? "Starting MySQL Service"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Securing MySQL Installation"

print_total_time
