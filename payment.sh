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
script_path=$PWD
START_TIME=$(date +%s)


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

dnf install python3 gcc python3-devel -y &>>$file_path
VALIDATE $? "Install Python3 packages"


id roboshop &>>$file_path

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$file_path
    validate $? "Roboshop user created"
else
    echo -e "$G roboshop user is already exist...$Y"skipping this step"$N" | tee -a $file_path
fi

mkdir -p /app 
validate $? "/app creation"

rm -rf /app/* &>>$file_path
validate $? "removing previous files from /app"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$file_path
validate $? "Downloading payment files using curl"

cd /app

unzip /tmp/payment.zip &>>$file_path
validate $? "unzipping"

pip3 install -r requirements.txt &>>$file_path
validate $? "installing pip"

cp $script_path/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload &>>$file_path
validate $? "Daemon-reload"

systemctl enable payment &>>$file_path
validate $? "enable payment"

systemctl start payment &>>$file_path
validate $? "start payment"



End_time=$(date +%s)
TOTAL_TIME=$(($End_time-$start_time))

echo -e "$G Time taken to this script $R$0: $Y$TOTAL_TIME seconds$N"



