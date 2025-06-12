#!/bin/bash

user=$(id -u)

start_time=$(date +%s)
##colors##

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Log_Folder="/var/log/roboshop-logs"
file_name=$(echo $0 | cut -d "." -f1)
file_path="$Log_Folder/$file_name.log"
script_path=$PWD


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
        echo -e "$G $2 Success...$Y"success"$N" | tee -a $file_path
fi
}


dnf module disable nodejs -y &>>$file_path
validate $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>$file_path
validate $? "Enable nodejs:20"

dnf install nodejs -y  &>>$file_path
validate $? "Installing nodejs"

id roboshop &>>$file_path

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$file_path
    validate $? "Roboshop user created"
else
    echo -e "$G roboshop user is already exist...$Y"skipping this step"$N" | tee -a $file_path
fi    

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$file_path

validate $? "Downloading Zip file" 

mkdir -p /app  &>>$file_path


rm -rf /app/* &>>$file_path
validate $? "Removing unnecessary files"

cd /app 

unzip /tmp/user.zip  &>>$file_path

validate $? "unzipping files"

npm install  &>>$file_path

validate $? "Installing NPM"

cp $script_path/user.service /etc/systemd/system/user.service &>>$file_path
validate $? "copying service file"

systemctl daemon-reload &>>$file_path
validate $? "Reloading the service"

systemctl enable user &>>$file_path

systemctl start user &>>$file_path

validate $? "starting user"

End_time=$(date +%s)
TOTAL_TIME=$(($End_time-$start_time))

echo -e "$G Time taken to this script $R$0: $Y$TOTAL_TIME seconds$N"
