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


echo "you are running this script at $(date)" | tee -a $file_path

mkdir -p $Log_Folder 

if [ $user -ne 0 ]
then
    echo -e "'$R Not a root user....$Y'please run the script with root user'$N'"  | tee -a $file_path
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
        echo -e "$G $2 Success...$Y Proceeding $N" | tee -a $file_path
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $file_path
validate $? "Copying Repo"

dnf install mongodb-org -y &>>$file_path
validate $? mongodb-install

systemctl enable mongod &>>$file_path
validate $? enable

systemctl start mongod &>>$file_path
validate $? start

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$file_path
validate $?  "Ip Addreess change"

systemctl restart mongod &>>$file_path
validate $? "restart of mongodb"

