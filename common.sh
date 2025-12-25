#!/bin/bash

USER_ID=$(id -u)
GROUP_ID=$(id -g)

#Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
N="\e[0m"

#Creating log file
LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="${LOG_FOLDER}/${SCRIPT_NAME}.log"
SCRIPT_DIR=$(pwd)
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.phemanth.in
REDIS_HOST=redis.phemanth.in
MYSQL_HOST=mysql.phemanth.in
RABBITMQ_HOST=rabbitmq.phemanth.in

mkdir -p $LOG_FILE
echo "Script Execution Started at : $(date)"  &>>${LOG_FILE} | tee -a $LOG_FILE

#Check root user
check_root_user() {
  if [ $USER_ID -ne 0 ] ; then
    echo -e "${RED}You should run this script as root user or with sudo privileges${N}"
    exit 1
  fi
}


#Check VALIDATE
VALIDATE() {
  if [ $1 -ne 0 ] ; then
    echo -e "${RED}Installation Failed. Check the log file for more details: ${LOG_FILE}${N}"
    exit 1
  else
    echo -e "${GREEN}Installation is Successful${N}"
  fi
}

# #Print Headings
# Print_Headings() {
#   echo -e "\n****************** $1 ******************" &>>${LOG_FILE}
#   echo -e "${BLUE}****************** $1 ******************${N}"
# }

# #Print Status
# Print_Status() {
#   echo -e "\n****************** $1 ******************" &>>${LOG_FILE}
#   echo -e "${YELLOW}****************** $1 ******************${N}"
# }

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling NodeJS"
    dnf module enable nodejs:20 -y  &>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS 20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Packing the application"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming the artifact"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "User already exist ... $Y SKIPPING $N"
    fi
    mkdir -p /app
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name application"

    cd /app 
    VALIDATE $? "Changing to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzip $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copy systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}
print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}
