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



dnf install maven -y
validate "Maven installation"

id roboshop

if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else  
    echo "roboshop user is already $G"exists""
fi

mkdir /app 
validate $? "/app folder installed"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $file_path
validate $? "shipping folder downloading"

unzip /tmp/shipping.zip &>> $file_path
validate $? "unzipping shipping folder"

mvn clean package 
validate $? "packaging the shipping application"


mv target/shipping-1.0.jar shipping.jar 
validate "moving to shipping.jar"

cp $script_path/shipping.sh /etc/systemd/system/shipping.service
validate $? "copying shipping service"

systemctl daemon-reload &>> $file_path
validate $? "daemon-reload"

systemctl enable shipping &>> $file_path
validate $? "enable shipping"

systemctl start shipping &>> $file_path
validate $? "start shipping"

dnf install mysql -y &>> $file_path
validate $? "mysql installation"

read -ps "please provide mysql root password : " MYSQL_PASSWORD


mysql -h mysql.anantya.space -u root -p$MYSQL_PASSWORD -e 'use cities' &>>$LOG_FILE

if [ $? -ne 0]
then
    mysql -h mysql.anantya.space -uroot -p$MYSQL_PASSWORD < /app/db/schema.sql &>> $file_path

    mysql -h mysql.anantya.space -uroot -p$MYSQL_PASSWORD < /app/db/app-user.sql &>> $file_path

    mysql -h mysql.anantya.space -uroot -p$MYSQL_PASSWORD < /app/db/master-data.sql  &>> $file_path
    validate $? "Loading data into mysql"
    
else
    echo "Data is loaded to mysql database"
fi        


systemctl restart shipping  &>> $file_path
validate $? "restarting shipping"

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME-$START_TIME))

echo -e "Time taken to run this script is : $G $TOTAL_TIME $N seconds" | tee -a $file_path













