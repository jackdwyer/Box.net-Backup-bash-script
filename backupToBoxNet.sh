#!/bin/sh
# JACK DWYER
# 05 October 2011
#------------------- 
# Backup Script
# Uses a webdav mounted box.net directory
# and rsync to backup specified files
#-------------------

#first check webdav mount of my box.net is up
grep -q box.net /etc/mtab
if [ $? -eq 1 ]; then
	mount ~/box.net
fi

#SOME GLOBAL VARIABLES
#-------------------
#This is path to the log rsynclog file
rs="/home/jack/Desktop/rSyncLog"

#SOURCE = the acutal location of backup directory
#DESTINATION = save location for the corresponding source
#source must match its destination
source=("/home/jack/Desktop/src")
destination=("/home/jack/Desktop/testDir")

#Check both source and destination array are matching length
if [ ${#source[@]} != ${#destination[@]} ]; then
	#TODO EMAIL error the backup can not be ran.
	echo "SOURCE AND DESTINATION ARRAYS DO NOT MATCH, backup can not be ran"
	exit 1
fi




#total length for the loop
backupLen=${#source[@]}

#-------------------
#Setup Up EMAIL MESSAGE - ONLY SENT IF THERE IS AN ERROR
echo "To: jackjack.dwyer@gmail.com" > $rs 
echo "From: jack@servesbeer.com" >> $rs 
echo "Subject: BACKUP ERROR OF VPS" >> $rs 
echo "" >> $rs 
echo "--------------------------------------------------------------------------------------------------------------------" >> $rs
echo "" >> $rs


#Generate a rsync commands
for (( i=0; i<=$(( $backupLen - 1)); i++ ))
do
	rSyncArray[$i]="rsync -a --log-file=${rs} ${source[$i]}  ${destination[$i]}"
done


errors=0
#--------------------
#Actually do the backups
for (( i=0; i<=$(( $backupLen - 1)); i++ ))
do
	${rSyncArray[$i]}
	if [ $? -gt 0 ]; then
        	errors=1
	fi

done

#Shoot off email to me, if the shit fucks up\
if [ $errors -gt 0 ]; then
	msmtp -t < ${rs}
fi



#TO DO DUMP DB to backup, and organse the actual backup locations and chosen directories.
