#!/bin/bash

user=$(id -u)

##colors##
start_time=$(date +%s)
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

dnf module disable redis -y
validate $? "Disable default redis module"

dnf module enable redis:7 -y
validate $? "Enable redis 7"

dnf install redis -y
validate $? "Installing redis"



#sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c 