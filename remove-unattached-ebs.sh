#!/bin/bash

###################################################################
#Script Name    : remove-unattached-ebs.sh
#Description    : Script to remove un-attached EBS volumes
#Author         : Maria de la Luz Perez
#Email          : maria_de_la_luz_perez@baxter.com
###################################################################



FILE=/var/tmp/volumelist.txt
FILE2=/var/tmp/volumeremoved.txt
FILE3=/var/tmp/snapshots.txt

> $FILE
> $FILE2
> $FILE3

clear
echo "What is the region you want to delete un-attached EBS Volumes?: <us-east-2|eu-central-1|ap-southeast-1>"
read regname
echo "-----------------------------------------------------------------------------------------------"
date
echo "This is running on AWS account `aws iam list-account-aliases --output text |awk {'print $2'} ` and region: $regname"

#keep list of unattached volumes in a file
aws ec2 describe-volumes --region $regname --query 'Volumes[*].{ID:VolumeId,InstanceId:Attachments[0].InstanceId,AZ:AvailabilityZone,Size:Size,Encrypted:Encrypted,State:State,CreateTime:Crea
teTime}' --output table > $FILE


#List Volumes that are unattached

for regions in $regname
do
        for volumes in `cat $FILE |grep available |awk {'print $7'}`
        do
          echo  $volumes >> $FILE2
        done
done

echo " "
echo " "

echo "This is the list of volumes that are un-attached and will be removed"
echo "_______________________________________________"

cat $FILE2

echo "_______________________________________________"







function deletevolumes
{
for ebs in $(cat $FILE2)
do
echo "Removing $ebs on region $regname"
#aws ec2 delete-volume --region $regname --volume-id $ebs --output text
done
exit
}


function backupvolumes
{
echo "Taking backup on volumes..."
for i in $(cat $FILE2 ); do
aws ec2 create-snapshot --region $regname --volume-id $i --description "Backup of $i on $(date)" --output text >> $FILE3

done
echo  " "
echo " "
for id in $(cat $FILE3 |awk {'print $13'})
do
sleep 5
echo $id
aws ec2 describe-snapshots --snapshot-ids $id  --region $regname |grep Progress
done

echo "After snapshot completed, We will proceed to remove volumes"

while true; do
    read -p "Are you sure (y/n)? " yn
    case $yn in
        [Yy]* ) deletevolumes; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

}


while true; do
     read -p " Are you want to proceed to remove volumes (y-yes/n-exit/s-take snapshot before)?"  yns
     case $yns in
        [Yy]* ) deletevolumes; break;;
        [Nn]* ) exit;;
        [Ss]* ) backupvolumes; break;;
        * ) echo "Please answer y,n or s";;
    esac
done

