#!/bin/bash

user_id=$(id -u)

##colors##

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/roboshop-logs"
file_name=$(echo "$0" | cut -d "." -f1)
file_path="$LOG_FOLDER/$file_name.log"
script_path=$PWD

mkdir -p /var/log/roboshop-logs

echo "you are running this script at: $(date)" | tee -a $script_path

if [ $user -ne 0 ]
then
    echo -e "$R Not a root user....$Y please run the script with root user'$N'"  | tee -a $file_path
    exit 1
else
    echo -e "'$G'Running with Root...'$Y'Proceeding...'$N'" | tee -a $file_path
fi


validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2 Failed...$Y please check $N" | tee -a $file_path
        exit 1
    else
        echo -e "$G $2 Success...$Y"success"$N" | tee -a $file_path
   fi
}


dnf module disable nginx -y &>>$file_path
dnf module enable nginx:1.24 -y  &>>$file_path
dnf install nginx -y  &>>$file_path
validate $? "Installing Nginx"

rm -rf /usr/share/nginx/html/* &>>$file_path
validate $? "removing Default content"

cp $script_path/nginx.conf /etc/nginx/nginx.conf
validate $? "copying nginx.conf file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$file_path
validate $? "Downloading frontendcontent"

cd /usr/share/nginx/html &>>$file_path
unzip /tmp/frontend.zip  &>>$file_path
validate $? "Extracting the frontend content"

systemctl enable nginx &>>$file_path
systemctl start nginx  &>>$file_path
validate $? "Starting Nginx"












