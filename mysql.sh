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



dnf install mysql-server -y &>>$file_path
validate $? "Installing mySQL server"

systemctl enable mysqld &>> $file_path
systemctl start mysqld  &>> $file_path
validate $? "starting mysql"

read -sp "please provide roboshop password" MYSQL_PASSWORD

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD 
validate $? "setting root password"

END_TIME=$(DATE +%S) 

TOTAL_TIME=$(($END_TIME-$START_TIME)) 

echo -e "Time taken to run this script is : $G $TOTAL_TIME $N seconds" | tee -a $file_path





