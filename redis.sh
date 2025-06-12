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

dnf module disable redis -y &>>$file_path
validate $? "Disable default redis module" | tee -a $file_path

dnf module enable redis:7 -y &>>$file_path
validate $? "Enable redis 7"  | tee -a $file_path

dnf install redis -y &>>$file_path
validate $? "Installing redis" | tee -a $file_path


sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$file_path
validate $? "Using sed changes ip and protected mode"  | tee -a $file_path



systemctl enable redis &>>$file_path
validate $? "Enable redis" | tee -a $file_path

systemctl start redis &>>$file_path
validate $? "Disable redis" | tee -a $file_path

End_time=$(date +%s)
TOTAL_TIME=$((End_time-start_time))

echo "Total time taken to run this script : $TOTAL_TIME seconds" | tee -a $file_path


