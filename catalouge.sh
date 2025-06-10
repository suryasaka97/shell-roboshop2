#!/bin/bash

user=$(id -u)

##colors##

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Log_Folder="/var/log/roboshop-logs"
file_name=$(echo $0 | cut -d "." -f1)
file_path="$Log_Folder/$file_name.log"
script_path=$(PWD)


mkdir -p $Log_Folder

echo "you are running this script at $(date)" | tee -a $file_path
 

if [ $user -ne 0 ]
then
    echo -e "$R Not a root user....$Y please run the script with root user$N"  | tee -a $file_path
    exit 1
else
    echo -e "$G Running with Root...$Y Proceeding...$N" | tee -a $file_path
fi


validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2 Failed...$Y please check $N" | tee -a $file_path
        exit 1
    else
        echo -e "$G $2 Success...$Y Proceeding $N" | tee -a $file_path
fi
}


dnf module disable nodejs -y &>>$file_path
validate $? "Disable default nodejs module"

dnf module enable nodejs:20 -y  &>>$file_path
validate $? "Enable nodejs:20 Module"

dnf install nodejs -y  &>>$file_path
validate $? "Installing Nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$file_path
validate $? "Creating Roboshop user"

mkdir /app 
validate $? "/app folder is created"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$file_path
validate $? "Downloading catalogue.zip to tmp folder"

cd /app 
validate $? "moving to /App"

unzip /tmp/catalogue.zip  &>>$file_path
validate $? "Unzipping catalogue zip file in /app folder"


cd /app 
npm install &>>$file_path
validate $? "npm installation"

cp $script_path/catalogue.service /etc/systemd/system/catalogue.service  &>>$file_path
validate $? "copying daemon path"

systemctl daemon-reload  &>>$file_path
validate $? "daemon-reload"

systemctl enable catalogue  &>>$file_path
systemctl start catalogue
validate $? "start catalogue"

cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo  &>>$file_path
validate $? "copying mongo repo"

dnf install mongodb-mongosh -y  &>>$file_path
validate $? "installing mongodb client"

mongosh --host mongodb.anantya.space </app/db/master-data.js  &>>$file_path
validate $? "Loading data into mongodb"


