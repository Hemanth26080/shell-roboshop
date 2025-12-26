#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/frontend.log
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD # for absoulute path
MONGODB_HOST=mongodb.phemanth.in
MYSQL_HOST=mysql.phemanth.in

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: Please run this script with root privelege"
        exit 1 # failure is other than 0
    fi
}


VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


# frontend component setup
dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx
systemctl start nginx
VALIDATE $? "Starting Nginx"

#frontend content setup
rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading frontend content"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Copying frontend content"

#nginx configuration
rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying Nginx config file"

#restart nginx
systemctl restart nginx
VALIDATE $? "Restarting Nginx" 
END_TIME=$(date +%s)
echo "Total time taken to execute the script: $((END_TIME-START_TIME)) seconds" 
