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

#Validate both source and destination array are matching length
if [ ${#source[@]} != ${#destination[@]} ]; then
	#TODO EMAIL error the backup can not be ran.
	echo "SOURCE AND DESTINATION ARRAYS DO NOT MATCH, backup can not be ran"
	exit 1
fi

#mysql setup values
password=a
user=root
sqlSource=("/home/jack/Desktop/mysqlDump.sql")
sqlDestination=("/home/jack/Desktop/dbDump")

#Validate sqlSource and sqlDestination are matching length
if [ ${#sqlSource[@]} != ${#sqlDestination[@]} ]; then
	#TODO append if an error to the error email
	echo "SQL BACKUP ARRAYS DO NOT MATCH, backup can not run"
	exit 1
fi

#Length of each array (sql, directories)
backupLen=${#source[@]}
mysqlLen=${#sqlSource[@]}

errors=0

#-------------------
#Setup Up EMAIL MESSAGE - ONLY SENT IF THERE IS AN ERROR
echo "To: jackjack.dwyer@gmail.com" > $rs 
echo "From: jack@servesbeer.com" >> $rs 
echo "Subject: BACKUP ERROR OF VPS" >> $rs 
echo "" >> $rs 
echo "--------------------------------------------------------------------------------------------------------------------" >> $rs
echo "" >> $rs


#dump mysql databases
mysqldump -u ${user} -p${password} --all-databases > ${sqlDump}


#Generate a rsync commands
for (( i=0; i<=$(( $backupLen - 1)); i++ ))
do
	rSyncArray[$i]="rsync -a --log-file=${rs} ${source[$i]}  ${destination[$i]}"
done

if [ $mysqlLen != 0 ]; then
	#First Generate SQL Dump file
	for (( i=0; i<=$(( $mysqlLen - 1)); i++ ))
	do
		#Build array for mysql dump files and location on box.net to store
	done

	#append the new rsync commands to directory rsnyc array
	for (( i=0; i<=$(( $mysqlLen -1)); i++ ))
	do
		#append the commands
	done
fi

#--------------------
#Actually do the backups
for (( i=0; i<=$(( $backupLen - 1)); i++ ))
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



#TO DO DUMP DB to backup, and organse the actual backup locations and chosen directories.
