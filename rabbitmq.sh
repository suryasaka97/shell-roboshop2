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

mkdir -p $Log_Folder

echo "you are running this script at $(date)" | tee -a $file_path
 

if [ $user -ne 0 ]
then
    echo -e "$R Not a root user....$Y please run the script with root user'$N'"  | tee -a $file_path
    exit 1
else
    echo -e "$G'Running with Root...'$Y'Proceeding...'$N" | tee -a $file_path
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


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $file_path
validate $? "copying rabbitmq to yum.repos.d"

dnf install rabbitmq-server -y &>> $file_path
validate $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>> $file_path
validate $? "Enabling rabbitmq"

systemctl start rabbitmq-server &>> $file_path
validate $? "starting rabbitmq"

rabbitmqctl list_users | grep "^roboshop"

if [ $? -ne 0 ]
then
    echo "Please enter rabbitmq password to setup"
    read -s RABBITMQ_PASSWD

    rabbitmqctl add_user roboshop $RABBITMQ_PASSWD  &>> $file_path
    validate $? "adding roboshop user"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $file_path
    validate $? "settingup permissions"
else
    "rabbitmq roboshop user already exists"
fi        






End_time=$(date +%s)
TOTAL_TIME=$(($End_time-$start_time))

echo "Total time taken to run this script : $TOTAL_TIME seconds" | tee -a $file_path
