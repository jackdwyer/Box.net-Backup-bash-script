#!/bin/sh
# JACK DWYER
# 06 October 2011
#------------------- 
# Backup Script
# Uses a webdav mounted box.net directory
# Can use any mounted path though, just comment out the first check
# and rsync to backup specified files
#-------------------

#first check webdav mount of my box.net is up
grep -q box.net /etc/mtab
if [ $? -eq 1 ]; then
	mount ~/box.net
fi

#SOME GLOBAL VARIABLES - THESE NEED TO BE SETUP
#-------------------
#This is path to the log rsynclog file
rs="/home/jack/logs/etc/rSyncLog" 	# This file neeeds to be created before script will run 
					# eg: nano /path/to/log/rSyncLog, then close and save

#SOURCE = the acutal location of backup directory
#DESTINATION = save location for the corresponding source
#source must match its destination
source=("/home/jack/my/shit/1" "/all/the/shit/2/")
destination=("/home/jack/box.net/myshitBACKUP1" "/home/jack/boxnet/ALLTHESHIT_BACKUP2")

#Validate both source and destination array are matching length
if [ ${#source[@]} != ${#destination[@]} ]; then
	#TODO EMAIL error the backup can not be ran.
	echo "SOURCE AND DESTINATION ARRAYS DO NOT MATCH, backup can not be ran"
	exit 1
fi

#mysql setup values
password=a
user=root
mysqlSource=("/home/jack/Desktop/WORKING.sql") #this is actually where the dump will be stored, good variable name
mysqlDestination=("/home/jack/box.net/mysqlbackup")

#Validate sqlSource and sqlDestination are matching length
if [ ${#sqlSource[@]} != ${#sqlDestination[@]} ]; then
	#TODO append if an error to the error email
	echo "SQL BACKUP ARRAYS DO NOT MATCH, backup can not run"
	exit 1
fi

#Length of each array (sql, directories)
dirLen=${#source[@]}
mysqlLen=${#mysqlSource[@]}

errors=0

#TODO check log files exist, if not create them.  As script will fail if they are not floating around

#-------------------
#Setup Up EMAIL MESSAGE - ONLY SENT IF THERE IS AN ERROR
echo "To: YOUR_EMAIL@gmail.com" > $rs 
echo "From: server@yours.com" >> $rs 
echo "Subject: BACKUP ERROR" >> $rs 
echo "" >> $rs 
echo "--------------------------------------------------------------------------------------------------------------------" >> $rs
echo "" >> $rs

#Generate a rsync commands
for (( i=0; i<=$(( $dirLen - 1)); i++ ))
do
	rSyncArray[$i]="rsync -a --log-file=${rs} ${source[$i]}  ${destination[$i]}"
done

#Generate mysqldump and rsnyc commands only if required
if [ $mysqlLen != 0 ]; then
	#Generate mysqldump commands, from the array of databases needed to be backed up
	for (( i=0; i<=$(( $mysqlLen - 1)); i++ ))
	do
		#Sort of point less loop  as its just doing a total dump, but could change so it specifed databases
		mysqlDump[$i]="mysqldump -u ${user} -p${password} --all-databases"
	done

	#run mysqldump with the specified matching location to save dump (mysqlSource)
	dumpLen=${#mysqlDump[@]}
	for (( i=0; i<=$(( $dumpLen - 1)); i++ ))
        do
		${mysqlDump[$i]} > ${mysqlSource[$i]}
	done

	#Creates new rsync commands, and adds them to the previous rsync command array
	for (( i=0; i<=$(( $dumpLen -1)); i++ ))
	do
		dumprSync="rsync -a --log-file=${rs} ${mysqlSource[$i]} ${mysqlDestination[$i]}"
		rSyncArray=("${rSyncArray[@]}" "${dumprSync}")
	done
fi



#Actually do the backups - EG: run the rsync commands
rSyncArrayLen=${#rSyncArray[@]}
for (( i=0; i<=$(( $rSyncArrayLen - 1)); i++ ))
do
	${rSyncArray[$i]}
	if [ $? -gt 0 ]; then
        	errors=1
	fi

done

#Shoot off email to me, if the shit fucks up
if [ $errors -gt 0 ]; then
	msmtp -t < ${rs}
fi
