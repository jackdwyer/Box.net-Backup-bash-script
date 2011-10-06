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
source=("/home/jack/Desktop/src" "fucked")
destination=("/home/jack/Desktop/testDir" "error")

#TODO check that  both source, and destination are same length

#total length for the loop
backupLen=${#source[@]}

#-------------------
#Setup Up EMAIL MESSAGE
echo "To: jackjack.dwyer@gmail.com" > $rs 
echo "From: jack@servesbeer.com" >> $rs 
echo "Subject: Backup Status" >> $rs 
echo "" >> $rs 
echo "--------------------------------------------------------------------------------------------------------------------" >> $rs
echo "" >> $rs


#Generate a rsync commands
for (( i=0; i<=$(( $backupLen - 1)); i++ ))
do
	rSyncArray[$i]="rsync -a --log-file=${rs} ${source[$i]}  ${destination[$i]}"
done

#--------------------
#Actually do the backups
for (( i=0; i<=$(( $backupLen - 1)); i++ ))
do
	${rSyncArray[$i]}
	#if [     			-check for errors 
	#echo "$?"
done

#Shoot off email to me, telling me about the shit
msmtp -t < ${rs}



#TO DO DUMP DB to backup, and organse the actual backup locations and chosen directories.
