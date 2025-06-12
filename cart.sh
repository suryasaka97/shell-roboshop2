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

dnf module disable nodejs -y &>> $file_path
validate $? "Disable default nodejs"
dnf module enable nodejs:20 -y &>> $file_path
validate $? "enable nodejs20"
dnf install nodejs -y &>> $file_path
validate $? "Installation of nodejs"
 
id roboshop &>> $file_path

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "to run cart service" roboshop
    validate $? "useradd roboshop"
else
    echo -e "$G roboshop user is already exist...$Y"skipping this step"$N" | tee -a $file_path
fi

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip | tee -a $file_path
validate $? "Downloading zip file"

mkdir -p /app

cd /app

rm -rf /app/* | tee -a $file_path
validate $? "removing all files from /app"

unzip /tmp/cart.zip | tee -a $file_path
validate $? "unzip all files in /app"

npm install &>> $file_path
validate $? "npm installation"

cp $script_path/cart.service /etc/systemd/system/cart.service
validate $? "copying script path"

systemctl daemon-reload &>> $file_path
validate $? "Demon reload"

systemctl enable cart &>> $file_path

systemctl start cart &>> $file_path
validate $? "start cart service"

End_time=$(date +%s)
TOTAL_TIME=$(($End_time-$start_time))

echo -e "$G Time taken to this script $R$0: $Y$TOTAL_TIME seconds$N" | tee -a $file_paths